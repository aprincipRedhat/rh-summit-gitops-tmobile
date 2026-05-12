# ACM Self-Serve Demo (Summit)

## Purpose

Three top-level GitOps areas:

- **`hub-clusters/`** — Hub lifecycle: Day 1 ACM + Vault Secrets Operator, Day 2 app-of-apps, per-application Helm charts, and per-hub `hub-env-values` values.
- **`spoke-clusters/`** — Per-hub spoke trees: policies, `99-pipeline-values/<cluster>.yaml`, and rendered manifests under `clusters/<cluster>/`.
- **`cluster-automation/`** — Shared Tekton pipeline charts (`spoke-automation`) and the **`ztp-spoke`** render chart at repo root of this subtree.
- **`custom-container-images/`** — Containerfiles for custom runner images (e.g. `oc-mirror`).

Install OpenShift **Pipelines** on the hub via Tekton pipeline Applications (separate from the OperatorPolicy exemplar, which targets GitOps only).

## Key Paths

| Path | Role |
|------|------|
| `hub-clusters/day1/acm-day1` | MCE, ACM operator, `MultiClusterHub`, Vault Secrets Operator (OLM; optional). |
| `hub-clusters/day2/app-of-apps` | Root OpenShift GitOps `Application` + `ApplicationSet` (`spoke-cluster-gitops-apps`). |
| `hub-clusters/day2/managed-applications` | Child `Application` Helm chart (`values.yaml` selects the `hub-env-values/.../values.yaml` path). |
| `hub-clusters/day2/applications/operator-installations` | OperatorPolicy chart (OpenShift GitOps, OpenShift Pipelines, etc.). |
| `hub-clusters/day2/applications/gitops-repos-config` | `VaultStaticSecret` resources for Argo CD repository credentials (Vault). |
| `hub-clusters/day2/applications/policy-generator-gitops-patch` | ArgoCD repo-server patch for PolicyGenerator. |
| `hub-clusters/day2/applications/ztp-configuration` | `ztp-common` namespace on the hub. |
| `hub-clusters/day2/applications/acm-spoke-clusters` | `policies` namespace + hub-template RBAC for operator pin ConfigMaps. |
| `hub-clusters/day2/applications/ztp-disconnected-configuration` | Disconnected hub: `OperatorHub`, mirrored `CatalogSource`, mirror `ConfigMap` for IDMS/ITMS YAML (Assisted Installer / ZTP); hub does not apply IDMS/ITMS CRs from this chart. |
| `hub-clusters/day2/applications/hub-platform-day2` | Optional hub proxy / trusted CA (values-driven). |
| `hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml` | Shared values for Day 2 Helm apps on that hub. |
| `cluster-automation/spoke-automation/*` | ZTP, bulk ZTP, and mirror Tekton pipeline charts. |
| `cluster-automation/ztp-spoke` | Helm chart rendered by the ZTP pipeline (`ClusterInstance`, etc.). |
| `custom-container-images/oc-mirror` | Container image build for the mirror pipeline runner. |
| `source-crs/` | Shared PolicyGenerator source manifests referenced by every hub’s **`spoke-clusters/.../policies/`** PolicyGenerator files. |
| `spoke-clusters/<env>/<site>/<hub>/policies` | PolicyGenerator (`common-gitops-config-pg.yaml`, `common-operatorpolicy-pg.yaml`). |
| `spoke-clusters/<env>/<site>/<hub>/99-pipeline-values/<cluster>.yaml` | Per-spoke inputs for `helm template`. |
| `spoke-clusters/<env>/<site>/<hub>/clusters/<cluster>/manifests.yaml` | Pipeline output; ApplicationSet watches `spoke-clusters/*/*/*/clusters/*`. |

## Quick Commands

```bash
# Day 1 ACM
helm template acm-day1 ./hub-clusters/day1/acm-day1 -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f -

# Day 2 bootstrap (root Application + ApplicationSet)
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -
```

## Next

- [AUTOMATION.md](AUTOMATION.md) — what we’re changing vs backlog (CI, validate scripts, hub drift).
- [hub-clusters/README.md](hub-clusters/README.md) — hub layout and install order.
- [spoke-clusters/README.md](spoke-clusters/README.md) — locked spoke directory convention.
- [cluster-automation/README.md](cluster-automation/README.md) — pipelines and render chart.
- [custom-container-images/README.md](custom-container-images/README.md) — custom images.
- [ACM install](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing)
- [GitOps with ACM](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html-single/gitops/index)
- [Policy Generator](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/governance/governance#integrating-policy-generator)
