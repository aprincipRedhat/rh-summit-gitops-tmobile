# Hub day 2 — GitOps (OpenShift GitOps)

Everything under **`hub/day2/gitops/`** is related to **OpenShift GitOps** (namespace **`openshift-gitops`**): bootstrap the root **Application**, define **child Applications** (app of apps), and optional **`openshift-gitops-repo-server`** patches for PolicyGenerator.

| Path | Purpose |
|------|---------|
| [`bootstrap/`](bootstrap) | Helm chart: root **`Application`**, **`ApplicationSet`** for `spokes/clusters/*`, and `rootApp.sourcePath` → **`managed-applications/`**. |
| [`managed-applications/`](managed-applications) | Kustomize: child **`Application`** manifests (OCP Pipelines charts, **`spokes/policies`**, etc.). |
| [`policy-generator-plugin/`](policy-generator-plugin) | Docs + example OpenShift GitOps **`ArgoCD`** CR patch so `kustomize build --enable-alpha-plugins` works for **`spokes/policies`**. |

Apply the bootstrap chart once (or manage it with Helm), then let the root Application sync **`managed-applications`** from Git.
