# vault-hub-configuration

Helm chart synced by Argo CD Application **`app-vault-hub-configuration`**: deploys **VaultConnection** and **VaultAuth** (Kubernetes auth) plus a **ServiceAccount** used by VSO in the Vault Secrets Operator namespace.

## Prerequisites

1. **Day 1** — Vault Secrets Operator subscribed ([`hub-clusters/day1/acm-day1`](../../../day1/acm-day1)) and bootstrap **`vault-bootstrap-credentials`** Secret applied (replace placeholders).
2. **Vault server** — reachable from the hub at **`vaultHubConfiguration.vaultConnection.address`**; Kubernetes auth backend configured with a role matching **`vaultAuth.kubernetes.role`**.
3. **Per-consumer namespaces** — **`VaultStaticSecret`** (for example from **`cluster-automation/ztp-spoke`**) requires a **`VaultAuth`** in the **same namespace** as the secret sync target; clone this **`VaultAuth`** or create namespace-local auth using the same Vault role pattern.

## Hub values

Configured via **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`** under **`vaultHubConfiguration`** (see defaults in [`values.yaml`](values.yaml)).

Enable the Application from **`hub-clusters/day2/managed-applications`** by setting **`vaultHubConfiguration.enabled: true`** in that hub environment file.

## Related

- Tekton pipeline Vault env: **`tektonZtp.vault.secretName`** — should match the replicated Secret name in **`openshift-pipelines`** (see **`hub-clusters/day2/applications/acm-hub-vault-credential-sync`** / **`policy-hub-vault-bootstrap-secret-sync`**).
- Bootstrap Secret keys: **`VAULT_ADDR`**, **`VAULT_TOKEN`**, **`secretId`** — Day 1 [`vault-bootstrap-secret.yaml`](../../../day1/acm-day1/templates/vault-bootstrap-secret.yaml) for VSO; ACM replication reads **`vault-hub-bootstrap-credentials`** in **`openshift-config`** when using **`app-acm-hub-vault-credential-sync`**.
