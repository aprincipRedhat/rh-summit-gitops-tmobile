# Hub clusters (`hub-clusters/`)

Hub lifecycle content for this GitOps repo.

## Layout

| Directory | Purpose |
|-----------|---------|
| `day1/` | Day 1 Helm chart: ACM / MCE / `MultiClusterHub` / optional Vault Secrets Operator (`acm-day1`). |
| `day2/app-of-apps/` | Bootstrap chart — root `Application` plus `ApplicationSet` for spoke manifest folders. |
| `day2/applications/` | Helm workload charts child Applications point at (`operator-installations`, `policy-generator-gitops-patch`, `ztp-configuration`, `ztp-disconnected-configuration`, `hub-platform-day2`, `vault-hub-configuration`). |
| `day2/managed-applications/` | Helm chart that renders OpenShift GitOps `Application` CRs (hub segment in `values.yaml`). |
| `day2/hub-env-values/` | Per-hub `values.yaml` files consumed via Argo `helm.valueFiles` (`<env>/<site>/<hub-cluster-name>/values.yaml`). |

## GitOps wiring

- Root Application **`root-day2-applications`** syncs **`hub-clusters/day2/managed-applications`** as Helm (see `app-of-apps/values.yaml` → `rootApp` and `rootApp.helmValueFiles` → `values.yaml` for hub identity).
- ApplicationSet **`clustersPath`** defaults to **`spoke-clusters/*/*/*/clusters`** so each `clusters/<spoke>/` directory becomes its own `Application`.
- Child Applications reference chart paths under **`hub-clusters/day2/applications/…`** or **`cluster-automation/spoke-automation/…`** and pull **`hub-clusters/day2/hub-env-values/.../values.yaml`**.

## Where next

- [day1/acm-day1/README.md](day1/acm-day1/README.md)
- [day2/README.md](day2/README.md)
- [day2/app-of-apps/README.md](day2/app-of-apps/README.md)
- [day2/hub-env-values/README.md](day2/hub-env-values/README.md)
