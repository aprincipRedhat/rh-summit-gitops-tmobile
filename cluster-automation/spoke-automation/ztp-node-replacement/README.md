# Chart: ztp-node-replacement

**Prefer [`ztp-pipeline`](../ztp-pipeline/README.md)** for new clusters: after **`clone-repos`**, **`detect-node-replacement`** chooses **`replacement-flow=full`** vs **`none`** and runs the same suppress → teardown → discovery → final MR path inside the main ZTP pipeline. This chart remains for hubs that still deploy **`app-tekton-node-replacement`** (`tektonNodeReplacement.enabled`).

Tekton **Pipeline** for bare-metal **node replacement**: suppress the marked node in **ClusterInstance** (Git MR), merge and wait, perform spoke teardown (with **etcd** manual gate for control-plane nodes), **Redfish MAC discovery**, final **helm template** + MR, optional **deploy watch**.

## Prerequisites

1. **Pipeline values** — In **`spoke-clusters/.../99-pipeline-values/<cluster>.yaml`**, set exactly **one** node with **`replacementTarget: true`** (and **`hostName`** matching the spoke **Node** name). YAML **`# comments` are not preserved** by the merge script—use this structured field.
2. **Hub ApplicationSet drift** — Enable **`applicationSet.ignoreDifferences`** in **`hub-clusters/day2/app-of-apps/values.yaml`** during replacement so **`ClusterInstance.spec.nodes`** drift does not thrash sync (see app-of-apps README).
3. **Secrets** — **`github-tekton-token`** (or **`tektonNodeReplacement.github`** overrides) for **`gh`**. Optional **`tektonNodeReplacement.vault.secretName`** for Ansible Redfish (same pattern as **`ztp-pipeline`**). Spoke **`kubeconfig`** Secret on the hub (**`<cluster>-admin-kubeconfig`** in **`cluster.namespace`** by default).
4. **RBAC** — Pipeline **`ServiceAccount`** (default **`pipeline-ztp-gitops`**) needs **`oc`** delete on **Node**/**Machine**/**BareMetalHost**, ConfigMap patch in **`openshift-pipelines`** (etcd gate), and **`get`** on the kubeconfig Secret.

## Enable (two toggles)

| Location | Key | Purpose |
|----------|-----|---------|
| **`hub-clusters/day2/managed-applications/values.yaml`** | **`tektonNodeReplacement.enabled: true`** | Renders Argo **`Application`** **`app-tekton-node-replacement`**. |
| **`hub-clusters/day2/99-environments/<hub>/values.yaml`** | **`tektonNodeReplacement.enabled: true`** | Renders the **`Pipeline`** CR from this chart. |

Images, GitHub Secret names, Ansible ConfigMap, and timeouts align with **`tektonNodeReplacement.*`** in that hub values file (defaults in this chart’s **`values.yaml`**).

**Diagrams** — Mermaid overview for this pipeline is in the **[cluster-automation README](../../README.md#pipeline-diagrams)** (`ztp-node-replacement` subsection). Source copies (`.mmd`) and optional rendered `.svg` files remain under [`diagrams/`](diagrams/) for tooling.

## Flow

1. **`clone-repos`** — Resolve **`99-pipeline-values/<cluster>.yaml`** (same discovery rules as **`ztp-pipeline`**).
2. **`merge-pipeline-values`** — **`merge_pipeline_values.py`** (base + **`discovered-nodes.yaml`** if present).
3. **`validate-replacement-marker`** — Exactly one **`replacementTarget`**; writes **`replacement-target-host.txt`**.
4. **`helm-render-suppress`** — **`helm template`** with **`nodeReplacement.omitMarkedNodes=true`** overlay → **`manifests.yaml`** without the marked node (suppress new BMC for that slot).
5. **`git-mr-suppress`** / **`wait-merge-suppress`** — GitHub PR; optional skips via params.
6. **`spoke-teardown-and-hub-cleanup`** — Spoke **`kubeconfig`**; if **control-plane**, etcd **ConfigMap** gate **`ztp-node-replacement-etcd-<cluster>`** in **`openshift-pipelines`** unless **`skip-etcd-manual-gate=true`** (danger). When **`execute-destructive=true`**: **`oc delete node`**, wait until **Machine** gone, **`oc delete baremetalhost`** on hub.
7. **`discover-node-network`** — Ansible preflight + MAC discovery (reuse **`ztp-ansible-preflight`** ConfigMap pattern).
8. **`merge-and-render-final`** — Re-merge with discovery; **`strip_replacement_marker.py`** clears **`replacementTarget`** from merged YAML; **`helm template`** full **`ClusterInstance`** (unsuppress provisioning).
9. **`git-mr-final`** / **`wait-merge-final`** — Second PR with refreshed manifests.
10. **`deploy-watch`** — Optional **`ClusterInstance`** Ready + **BMH** watch (**`skip-deploy-watch`**).

## Params (high level)

| Param | Notes |
|-------|------|
| **`skip-suppress-mr`** | Skip suppress-phase MR if suppression already applied. |
| **`skip-wait-merge-suppress`** / **`skip-wait-merge-final`** | CI shortcuts. |
| **`skip-etcd-manual-gate`** | Only after completing [OpenShift etcd member removal](https://docs.openshift.com/container-platform/latest/backup_and_restore/control_plane_backup_and_restore/replacing-unhealthy-etcd-member.html) for control-plane nodes. |
| **`execute-destructive`** | **`false`** (default): no **`oc delete`**. **`true`**: delete node / BMH. |

## GitOps

- Chart: **`cluster-automation/spoke-automation/ztp-node-replacement/`**
- Application: **`hub-clusters/day2/managed-applications/templates/application-tekton-node-replacement.yaml`**

## Local render

```bash
helm template nr ./cluster-automation/spoke-automation/ztp-node-replacement \
  --set tektonNodeReplacement.enabled=true \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml
```

## Related

- **`ztp-spoke`** **`nodeReplacement.omitMarkedNodes`** — [../../ztp-spoke/README.md](../../ztp-spoke/README.md)
- Main ZTP pipeline — [../ztp-pipeline/README.md](../ztp-pipeline/README.md)
- ApplicationSet drift — [../../../hub-clusters/day2/app-of-apps/README.md](../../../hub-clusters/day2/app-of-apps/README.md)
