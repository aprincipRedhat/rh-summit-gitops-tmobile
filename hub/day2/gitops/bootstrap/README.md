# gitops/bootstrap (Helm: OpenShift GitOps bootstrap)

Renders:

1. **`ApplicationSet`** — git **directory** generator on `spokes/clusters/*` by default (see `clustersPath` in `values.yaml`). Each subdirectory becomes one OpenShift GitOps **`Application`** syncing that path to the **hub** (in-cluster API `https://kubernetes.default.svc`), namespace = directory name (`CreateNamespace=true`).
2. **Root `Application`** — app-of-apps pattern syncing **`hub/day2/gitops/managed-applications`** (Kustomize) from the same Git repo so you can add child `Application` manifests there.

OpenShift GitOps **`Application`** / **`ApplicationSet`** resources are rendered in **`openshift-gitops`** and use the default **AppProject** **`default`**; you do not set those in `values.yaml`.

## Configure

Edit `values.yaml`:

- `repoURL` / `targetRevision` — must match the GitOps repo where OCP Pipelines pushes `spokes/clusters/<name>/` (defaults).
- `clustersPath` — prefix before `/*` (default `spokes/clusters`).
- `rootApp.sourcePath` — Kustomize folder for child **Applications** (default `hub/day2/gitops/managed-applications`).

## Apply (hub)

From this directory:

```bash
helm template argocd-bootstrap . -f values.yaml | oc apply -f -
```

Or from repo root:

```bash
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```

Requires **OpenShift GitOps** already installed and permissions for the OpenShift GitOps application controller to reconcile `ClusterInstance` and related hub resources.

## ApplicationSet templates

Go templating uses `{{`{{.path.basename}}`}}` style expressions in the rendered manifest (see `templates/applicationset.yaml`). If your OpenShift GitOps version expects different variable names, adjust per [ApplicationSet documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/).
