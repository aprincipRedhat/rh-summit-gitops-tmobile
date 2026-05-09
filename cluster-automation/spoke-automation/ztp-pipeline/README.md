# Chart: ztp-pipeline

Tekton **Pipeline** that renders **`cluster-automation/ztp-spoke`** manifests, opens a GitHub PR, optionally waits for merge, watches provisioning on the hub, and optionally validates the spoke cluster and runs **kube-burner**.

## Flow

1. **`clone-repos`** — Shallow **`git clone`**, resolve exactly one **`**/99-pipeline-values/<cluster>.yaml`**, write **`pipeline-values.path`** and **`fleet-context.env`** (`cluster-exists` hint).
2. **`preflight-sdn`** — When **`run-sdn-prechecks=true`**, HTTP GET **`sdnValidation.healthUrl`** from pipeline values (requires **`sdnValidation:`** block).
3. **`get-mac-addresses`** — Ansible with **`--tags`** derived from **`run-hardware-validation`** / **`run-network-connectivity-test`**, or **`ansible-tags`** override when non-empty (explicit mode).
4. **`preflight-network`** — When **`run-network-connectivity-test=true`**, reads **`networkValidation.mode`**; **`iso`** fails fast (integrate customer ISO/Redfish tooling outside this repo).
5. **`manual-approval-gate`** — When **`skip-manual-approval-gate=false`**, creates **`ConfigMap ztp-manual-<cluster>-approval`** in **`openshift-pipelines`** with **`data.approved=false`** until Operators patch **`approved=true`** (see RBAC on **`pipeline-ztp-gitops`**).
6. **`generate-cluster-files`** — Validates **`cluster.name`**, **`helm lint`** + **`helm template`** → **`manifests.yaml`**.
7. **`git-commit-and-mr`** / **`wait-for-merge`** — GitHub PR workflow ( **`GH_TOKEN`** Secret ).
8. **`deploy-cluster`** — **`oc`** watch **ClusterInstance** Ready and logs **AgentClusterInstall** status.
9. **`post-deploy-validation`** — When **`run-post-deploy-validation`** or **`run-kube-burner-tests`**, reads spoke **`kubeconfig`** from hub Secret (**`<cluster>-admin-kubeconfig`** by default in **`cluster.namespace`**); waits for **ClusterOperators** / **MachineConfigPools**; optional **kube-burner** **`init`** using **`files/kube-burner/profile.yml`**.

## Pipeline parameters (BO2299 toggles)

| Param | Default | Meaning |
|-------|---------|---------|
| **`run-sdn-prechecks`** | false | HTTP SDN health check |
| **`run-hardware-validation`** | true | Ansible tags **hardware,bmc,redfish** (managed tag mode) |
| **`run-network-connectivity-test`** | true | Ansible **ping** + network stub |
| **`skip-manual-approval-gate`** | true | Set **false** to require ConfigMap approval |
| **`run-post-deploy-validation`** | false | Spoke ClusterOperator / MCP checks (**kubeconfig** RBAC required) |
| **`run-kube-burner-tests`** | false | Smoke workload (**kube-burner** image in **`tektonZtp.images.kubeBurner`**) |

## Hub values (`tektonZtp`)

Set in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`manualApproval.timeoutSeconds`** — Manual gate polling cap (surfaced as Pipeline default).
- **`clusterValidation.timeoutSeconds`** — Post-deploy wait surfaces.
- **`images.kubeBurner`** — Pin kube-burner image for optional benchmarks.

### RBAC

- **`Role`** **`pipeline-ztp-gitops`** includes **ConfigMap** create/patch in **`openshift-pipelines`** for manual approvals.
- Grant **`get`** on the spoke **`kubeconfig`** **Secret** in its hub namespace (often same as **`cluster.namespace`**) for post-deploy steps.

## Pipeline values (optional blocks)

Documented in **`spoke-clusters/.../99-pipeline-values/README.md`**: **`sdnValidation.healthUrl`**, **`networkValidation.mode`** (**ping** vs **iso**).

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
- Node replacement skeleton: [../ztp-node-replacement/README.md](../ztp-node-replacement/README.md)
