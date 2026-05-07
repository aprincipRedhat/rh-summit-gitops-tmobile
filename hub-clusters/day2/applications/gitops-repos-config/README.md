# Chart: `gitops-repos-config`

Renders **`VaultStaticSecret`** resources (HashiCorp Vault Secrets Operator) so credentials from Vault sync into **`openshift-gitops`** as **`Secret`** objects Argo CD can use for private Git repositories.

## Prerequisites

- **Vault Secrets Operator** installed (see **`hub-clusters/day1/acm-day1`**).
- **`VaultAuth`** / **`VaultConnection`** CRs in the same namespace as each **`VaultStaticSecret`** (typically **`openshift-gitops`**), configured for your Vault deployment.
- Vault KV paths and keys aligned with the Kubernetes **`Secret`** shape Argo expects (`username`/`password`, `sshPrivateKey`, etc. — see OpenShift GitOps documentation for repository credentials).

## Values (`gitopsReposConfig`)

Set under **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`enabled`** — master switch.
- **`defaultNamespace`** — namespace for resources that omit **`namespace`** per entry (default **`openshift-gitops`**).
- **`vaultStaticSecrets`** — list of objects: **`name`**, **`namespace`** (optional), **`vaultAuthRef`**, **`mount`**, **`path`**, **`type`** (default **`kv-v2`**), optional **`refreshAfter`**, **`destination`** (`name`, **`create`**, optional **`labels`** / **`annotations`** / **`overwrite`** / **`type`**).

Label **`destination.labels`** with Argo secret types, for example:

- `argocd.argoproj.io/secret-type: repository` — repo HTTPS/SSH
- `argocd.argoproj.io/secret-type: repo-creds` — credential templates

## GitOps Application

Rendered by **`managed-applications`** → **`app-gitops-repos-config`**, destination **`openshift-gitops`**.

## Local render

```bash
helm template gitops-repos-config ./hub-clusters/day2/applications/gitops-repos-config \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml
```
