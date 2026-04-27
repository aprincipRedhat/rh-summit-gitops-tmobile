# Hub Day 2

## Purpose

Day 2 configures GitOps-managed automation on the hub:

- OpenShift GitOps bootstrap
- Day 2 managed applications
- Tekton pipelines (ZTP, bulk ZTP, mirror)
- Hub operator policy chart

## Key Paths

| Path | What it does |
|------|---------------|
| `gitops/bootstrap/` | Root `Application` + `ApplicationSet` bootstrap chart. |
| `gitops/managed-applications/` | Child applications synced by root app. |
| `helm/ocp-operators-policy/` | OperatorPolicy resources for GitOps/Pipelines operators. |
| `helm/tekton-ztp-pipeline/` | Single-cluster ZTP render + PR pipeline. |
| `helm/tekton-bulk-ztp-pipeline/` | Bulk fan-out pipeline per ManagedCluster. |
| `helm/tekton-mirror-pipeline/` | `oc mirror` pipeline + RBAC. |
| `../hub-values/` | Shared Day 2 values for all hub Helm apps. |

## Apply (from repo root)

```bash
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
helm template ocp-operators-policy ./hub/day2/helm/ocp-operators-policy -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
helm template tekton-ztp ./hub/day2/helm/tekton-ztp-pipeline -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
helm template tekton-bulk-ztp ./hub/day2/helm/tekton-bulk-ztp-pipeline -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
helm template tekton-mirror ./hub/day2/helm/tekton-mirror-pipeline -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Next

- GitOps details: `gitops/README.md`
- Spoke values: `../../spokes/pipeline-values/README.md`
- Spoke policies: `../../spokes/policies/README.md`
