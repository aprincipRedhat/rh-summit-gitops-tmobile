# App of apps (`hub-clusters/day2/app-of-apps`)

Helm chart that renders:

- **Root `Application`** — renders child Application manifests from **`hub-clusters/day2/managed-applications`** as Helm (`rootApp.sourcePath`, `rootApp.helmReleaseName`, `rootApp.helmValueFiles`).
- **`ApplicationSet`** — git directory generator over **`spoke-clusters/*/*/*/clusters/*`** (`clustersPath`), creating one OpenShift GitOps `Application` per spoke folder under `clusters/<spoke-cluster-name>/`.

## Values (`values.yaml`)

- **`repoURL`** / **`targetRevision`** — Git source for both the root Application and ApplicationSet.
- **`clustersPath`** — Prefix for rendered spoke manifests (default `spoke-clusters/*/*/*/clusters`).
- **`rootApp.sourcePath`** — Helm chart path for child `Application` CRs.
- **`rootApp.helmReleaseName`** / **`rootApp.helmValueFiles`** — Argo CD Helm options for that chart (default includes `values.yaml` next to **`hub-clusters/day2/managed-applications/Chart.yaml`**).

Only Git coordinates and paths belong here (no workload business logic).

## Apply

From the repository root:

```bash
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -
```

## Where next

- Child Applications index: [../managed-applications/README.md](../managed-applications/README.md)
- Spoke layout: [../../../spoke-clusters/README.md](../../../spoke-clusters/README.md)
