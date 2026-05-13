# Chart: ztp-node-replacement

> **Prefer `ztp-pipeline`** — the same replacement flow is integrated there (`detect-node-replacement` → `replacement-flow=full`). This chart is for hubs still using `app-tekton-node-replacement`.

Standalone Tekton Pipeline for bare-metal node replacement: suppress node in `ClusterInstance` (Git MR), teardown with etcd gate, Redfish MAC discovery, final `helm template` + MR, deploy watch.

## Enable

| Location | Key |
|----------|-----|
| `hub-clusters/day2/managed-applications/values.yaml` | `tektonNodeReplacement.enabled: true` |
| `hub-clusters/day2/hub-env-values/<hub>/values.yaml` | `tektonNodeReplacement.enabled: true` |

## Prerequisites

1. Set exactly one node with `replacementTarget: true` in `spoke-clusters/.../99-pipeline-values/<cluster>.yaml`.
2. Enable `applicationSet.ignoreDifferences` in `app-of-apps/values.yaml` during replacement to prevent `ClusterInstance.spec.nodes` sync thrash.
3. `github-tekton-token` Secret + optional Vault Secret for Ansible Redfish + spoke `kubeconfig` Secret on the hub.

## Key params

| Param | Notes |
|-------|-------|
| `skip-etcd-manual-gate` | Only set after completing OpenShift etcd member removal. |
| `execute-destructive` | `false` (default): no `oc delete`. `true`: delete node/BMH. |
| `skip-suppress-mr` / `skip-wait-merge-*` | Skip phases already completed. |

## Local render

```bash
helm template nr ./cluster-automation/spoke-automation/ztp-node-replacement \
  --set tektonNodeReplacement.enabled=true \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml
```
