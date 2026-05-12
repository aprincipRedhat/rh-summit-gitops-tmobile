# Chart: `gitops-repos-config`

Renders **`VaultStaticSecret`** resources (HashiCorp Vault Secrets Operator) so credentials from Vault sync into **`openshift-gitops`** as **`Secret`** objects Argo CD can use for private Git repositories.

## Prerequisites

- **Vault Secrets Operator** installed (see **`hub-clusters/day1/acm-day1`**).
- A **namespaced** **`vaultAuthRef`** on each **`VaultStaticSecret`** (for example **`vault-secrets-operator/vault-auth`**) and a **Secret** in the **same** namespace as the **`VaultStaticSecret`**, named per hub **`vaultHubConfiguration.vaultAuth.appRole.secretRef`**, with data key **`id`** (AppRole secret ID). **`VaultConnection`** / **`VaultAuthGlobal`** / **`VaultAuth`** are defined once in the VSO namespace — see **[`vault-hub-configuration`](../vault-hub-configuration/README.md)**.
- Vault KV paths and keys aligned with the Kubernetes **`Secret`** shape Argo expects (`username`/`password`, `sshPrivateKey`, etc. — see OpenShift GitOps documentation for repository credentials).

## Values (`gitopsReposConfig`)

Set under **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`enabled`** — master switch.
- **`defaultNamespace`** — namespace for resources that omit **`namespace`** per entry (default **`openshift-gitops`**).
- **`vaultStaticSecrets`** — list of objects: **`name`**, **`namespace`** (optional), **`vaultAuthRef`** (for global hub auth use **`vault-secrets-operator/vault-auth`** style `namespace/name`), **`mount`**, **`path`**, **`type`** (default **`kv-v2`**), optional **`refreshAfter`**, **`destination`** (`name`, **`create`**, optional **`labels`** / **`annotations`** / **`overwrite`** / **`type`**).

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
