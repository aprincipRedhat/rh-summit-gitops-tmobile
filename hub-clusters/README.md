# Hub clusters (`hub-clusters/`)

| Directory | Purpose |
|-----------|---------|
| `day1/acm-day1/` | ACM / MCE / `MultiClusterHub` / Vault Secrets Operator (Helm, manual apply). |
| `day2/app-of-apps/` | Bootstrap chart — root ArgoCD `Application` + `ApplicationSet` for spoke manifest folders. |
| `day2/applications/` | Workload Helm charts that child Applications point at. |
| `day2/managed-applications/` | Helm chart that renders all child ArgoCD `Application` CRs. |
| `day2/hub-env-values/` | Per-hub `<env>/<site>/<hub>/values.yaml` merged into every Day 2 chart. |

Root Application **`root-day2-applications`** syncs **`managed-applications`**. Every child Application pulls the matching `hub-env-values/.../values.yaml` via `helm.valueFiles`. The ApplicationSet watches `spoke-clusters/*/*/*/clusters` so each rendered spoke folder becomes its own sync target.
