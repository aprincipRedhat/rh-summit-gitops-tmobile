# ACM Self-Serve Demo (Summit)

## Purpose

This repo has two main areas:

- `hub/`: hub cluster bootstrap and Day 2 automation.
- `spokes/`: spoke templates, policies, and generated manifests.

## Key Paths

| Path | What it does |
|------|---------------|
| `hub/day1/` | Installs MCE, ACM operator, and `MultiClusterHub`. |
| `hub/day2/` | GitOps bootstrap, Tekton pipelines, mirror tooling, operator policies. |
| `hub/day2/helm/ztp-pipeline` | ZTP render + PR pipeline chart. |
| `hub/day2/helm/bulk-ztp-pipeline` | Bulk ZTP fan-out pipeline chart. |
| `hub/day2/helm/mirror-pipeline` | `oc mirror` pipeline chart. |
| `hub/hub-values/` | Per-hub values used by Day 2 Helm apps (`<env>/<site>/hub-values/<hub>.yaml`). |
| `spokes/cluster-automation/` | `ztp-spoke` Helm chart used to render cluster manifests. |
| `spokes/pipeline-values/` | Per-cluster input values (`**/pipeline-values/<cluster>.yaml`). |
| `spokes/policies/` | PolicyGenerator + Kustomize policy sources. |
| `spokes/clusters/` | Generated cluster manifests synced by ApplicationSet. |

## Quick Commands

```bash
# Day 1
helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -

# Day 2 bootstrap
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```

## Next

- Hub install order and Day 2 commands: [hub/README.md](hub/README.md), [hub/day2/README.md](hub/day2/README.md)
- [ACM install](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing)
- [GitOps with ACM](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html-single/gitops/index)
- [Policy Generator](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/governance/governance#integrating-policy-generator)
