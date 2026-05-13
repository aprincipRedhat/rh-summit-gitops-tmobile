# App of apps (`hub-clusters/day2/app-of-apps`)

Renders two ArgoCD resources:

- **Root `Application`** — syncs `hub-clusters/day2/managed-applications` as Helm, which in turn renders all child Applications.
- **`ApplicationSet` `spoke-cluster-gitops-apps`** — git directory generator over `spoke-clusters/*/*/*/clusters/*`; one Application per spoke cluster folder.

## Key values

- `repoURL` / `targetRevision` — Git source for root Application and ApplicationSet.
- `clustersPath` — path glob for spoke manifest directories (default `spoke-clusters/*/*/*/clusters`).
- `applicationSet.ignoreDifferences` — when enabled, spoke Applications ignore `ClusterInstance.spec.nodes` drift. Enable during node replacement; disable after.

```bash
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps \
  -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -
```
