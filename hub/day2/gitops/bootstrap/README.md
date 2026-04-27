# GitOps Bootstrap Chart

## Purpose

This chart creates:

- Root `Application` that syncs `hub/day2/gitops/managed-applications`
- `ApplicationSet` that watches `spokes/clusters/*`

## Inputs

Edit `values.yaml`:

- `repoURL`
- `targetRevision`
- `clustersPath`
- `rootApp.sourcePath`

## Apply

```bash
helm template argocd-bootstrap . -f values.yaml | oc apply -f -
```

From repo root:

```bash
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```
