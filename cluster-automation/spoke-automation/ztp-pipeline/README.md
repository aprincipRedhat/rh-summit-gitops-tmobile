# Chart: ztp-pipeline

Tekton **Pipeline** that renders **`cluster-automation/ztp-spoke`** manifests, opens a GitHub PR, optionally waits for merge, watches provisioning on the hub, and optionally validates the spoke cluster and runs **kube-burner**. When pipeline values and Git state indicate a **bare-metal node replacement**, a parallel branch runs (suppress MR, etcd gate, destructive teardown only when allowed, MAC discovery, **final render → Git MR → wait merge → hub `ClusterInstance` hostname sync after Argo applies**, then deploy watch).

## Flow

1. **`clone-repos`** — Shallow **`git clone`**, resolve exactly one **`**/99-pipeline-values/<cluster>.yaml`**, write **`pipeline-values.path`** and **`fleet-context.env`** (`cluster-exists` hint).
2. **`detect-node-replacement`** — **`detect_cluster_replacement.py`** emits **`replacement-flow`** **`none`** or **`full`** (compare **`replacementTarget`** / hostnames vs rendered **`manifests.yaml`** when the cluster already exists).
3. **`preflight-sdn`** — When **`run-sdn-prechecks=true`**, HTTP GET **`sdnValidation.healthUrl`** from pipeline values (requires **`sdnValidation:`** block). Skipped when **`replacement-flow=full`** (replacement tasks run instead of the standard prefix).
4. **`discover-node-network`** — Ansible preflight from **`files/ansible/`** (DNS, ping, hardware/Redfish, **`redfish_mac_discovery`** when **`run-mac-discovery=true`**). With hostname-only inventory (`nodeHostnames`), reads **`VAULT_ADDR`** / **`VAULT_TOKEN`** (optional **`tektonZtp.vault.secretName`** Secret in **`openshift-pipelines`**), queries Redfish for NIC MACs, writes **`discovered-nodes.yaml`** on the workspace PVC.
5. **`preflight-network`** — When **`run-network-connectivity-test=true`**, reads **`networkValidation.mode`**; **`iso`** fails fast (integrate customer ISO/Redfish tooling outside this repo).
6. **`manual-approval-gate`** — When **`skip-manual-approval-gate=false`**, creates **`ConfigMap ztp-manual-<cluster>-approval`** in **`openshift-pipelines`** with **`data.approved=false`** until Operators patch **`approved=true`** (see RBAC on **`pipeline-ztp-gitops`**).
7. **`generate-cluster-files`** — **`merge_pipeline_values.py`** merges base pipeline values + **`discovered-nodes.yaml`** when present → **`merged-pipeline-values.yaml`**; **`expand_node_inventory.py`** materializes **`nodes[]`** from **`nodeGroups`** when needed; validates **`cluster.name`** and inventory via **`node_inventory.py check-render`**; **`helm lint`** + **`helm template`** → **`manifests.yaml`**.
8. **`git-commit-and-mr`** / **`wait-for-merge`** — GitHub PR workflow (**`GH_TOKEN`** Secret).
9. **`deploy-cluster`** — **`oc`** watch **ClusterInstance** Ready and logs **AgentClusterInstall** status (reads merged values when available).
10. **`post-deploy-validation`** — When **`run-post-deploy-validation`** or **`run-kube-burner-tests`**, reads spoke **`kubeconfig`** from hub Secret (**`<cluster>-admin-kubeconfig`** by default in **`cluster.namespace`**); waits for **ClusterOperators** / **MachineConfigPools**; optional **kube-burner** **`init`** using **`files/kube-burner/profile.yml`**.

When **`replacement-flow=full`**, Tekton runs **`replacement-*`** tasks (merge/validate marker, suppress **`helm`** + Git MR + wait, teardown with etcd gate and optional **`oc delete`**, discovery, final merge + strip marker + **MR + wait merge**, then hub **`ClusterInstance`** host sync wait so Argo can apply unsuppressed manifests / new BMH, then deploy watch). See **`files/scripts/detect_cluster_replacement.py`** and **`templates/_pipeline_node_replacement.tpl`**.

## Pipeline parameters (BO2299 toggles)

| Param | Default | Meaning |
|-------|---------|---------|
| **`run-sdn-prechecks`** | false | HTTP SDN health check |
| **`run-hardware-validation`** | true | Ansible tags **hardware,bmc,redfish** (managed tag mode) |
| **`run-network-connectivity-test`** | true | Ansible **ping** + network stub |
| **`run-mac-discovery`** | true | Adds **`mac-discovery`** tag; hostname-only inventory requires Vault + Redfish (set **false** only if **`nodes`** already include MACs). |
| **`skip-manual-approval-gate`** | true | Set **false** to require ConfigMap approval |
| **`run-post-deploy-validation`** | false | Spoke ClusterOperator / MCP checks (**kubeconfig** RBAC required) |
| **`run-kube-burner-tests`** | false | Smoke workload (**kube-burner** image in **`tektonZtp.images.kubeBurner`**) |
| **`skip-replacement-suppress-mr`** | false | Replacement path: skip first MR if suppression already merged |
| **`skip-replacement-wait-merge-suppress`** / **`skip-replacement-wait-merge-final`** | false | CI shortcuts for replacement MR waits |
| **`replacement-execute-destructive`** | false | **`true`**: replacement path may **`oc delete`** node / BMH after etcd gate |
| **`replacement-skip-etcd-manual-gate`** | false | **`true`**: skip etcd ConfigMap pause (dangerous) |
| **`skip-replacement-deploy-watch`** | false | Skip replacement deploy watch |
| **`pr-title-replacement-suppress`** / **`pr-title-replacement-final`** | (defaults) | Git PR titles for the two replacement MRs |

When **`ansible-tags`** is non-empty, it overrides managed tag selection (you must include **`mac-discovery`** yourself if you rely on Redfish MAC discovery).

## Hub values (`tektonZtp`)

Set in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`manualApproval.timeoutSeconds`** — Manual gate polling cap (surfaced as Pipeline default).
- **`clusterValidation.timeoutSeconds`** — Post-deploy wait surfaces.
- **`images.kubeBurner`** — Pin kube-burner image for optional benchmarks.
- **`vault.secretName`** — Optional Secret in **`openshift-pipelines`** whose keys **`VAULT_ADDR`** and **`VAULT_TOKEN`** are injected into the Ansible step for Vault KV reads (same paths as **`VaultStaticSecret`** in **`ztp-spoke`**).
- **`nodeReplacement.etcdManualGate.timeoutSeconds`**, **`nodeReplacement.hubSyncWaitSeconds`** — Replacement branch only; etcd ConfigMap gate cap and post-merge poll until hub **`ClusterInstance.spec.nodes`** hostnames match merged values (Argo sync after final MR merge).

### RBAC

- **`Role`** **`pipeline-ztp-gitops`** includes **ConfigMap** create/patch in **`openshift-pipelines`** for manual approvals.
- Grant **`get`** on the spoke **`kubeconfig`** **Secret** in its hub namespace (often same as **`cluster.namespace`**) for post-deploy steps.

### Vault prerequisite

Set **`vault.vaultAuthRef`** to a **namespaced** reference (for example **`vault-secrets-operator/vault-auth`**) so **`VaultStaticSecret`** resources use the **single** hub **`VaultAuth`** tied to **`VaultAuthGlobal`** (see **`hub-clusters/day2/applications/vault-hub-configuration`**). Each **`cluster.namespace`** needs only a **`Secret`** named per hub **`vaultHubConfiguration.vaultAuth.appRole.secretRef`** with key **`id`** for the AppRole secret ID — replicate with **[`acm-hub-vault-credential-sync`**](../../../hub-clusters/day2/applications/acm-hub-vault-credential-sync/README.md) or equivalent. Repo credentials use the same pattern in **[`gitops-repos-config`**](../../../hub-clusters/day2/applications/gitops-repos-config/README.md).

## Pipeline values (optional blocks)

See **`spoke-clusters/.../99-pipeline-values/README.md`**: **`sdnValidation.healthUrl`**, **`networkValidation.mode`**, hostname-only **`nodeHostnames`**, **`clusterNetworking`**, **`vault`** paths.

## GitOps

- Chart: **`cluster-automation/spoke-automation/ztp-pipeline/`**
- Application: [`application-tekton-ztp.yaml`](../../../hub-clusters/day2/managed-applications/templates/application-tekton-ztp.yaml)

## Local render

```bash
helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```

## Related

- Render chart: [../../ztp-spoke/README.md](../../ztp-spoke/README.md)
- Legacy standalone replacement chart (same scripts now live under this chart): [../ztp-node-replacement/README.md](../ztp-node-replacement/README.md)
