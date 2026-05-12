# vault-hub-configuration

Helm chart synced by Argo CD Application **`app-vault-hub-configuration`**: deploys **one `VaultConnection`**, **one `VaultAuthGlobal`** (shared Vault URL, AppRole **role ID**, and auth engine defaults), and **one `VaultAuth`** in the Vault Secrets Operator namespace. Consumer namespaces (ZTP spoke namespaces, **`openshift-gitops`**, etc.) only need a **Kubernetes `Secret`** holding the AppRole **secret ID** under key **`id`**, named by **`vaultHubConfiguration.vaultAuth.appRole.secretRef`**.

## Prerequisites

1. **Day 1** — Vault Secrets Operator subscribed ([`hub-clusters/day1/acm-day1`](../../../day1/acm-day1)) and bootstrap **`vault-bootstrap-credentials`** / hub **`vault-hub-bootstrap-credentials`** applied (replace placeholders).
2. **Vault server** — reachable from the hub at **`vaultHubConfiguration.vaultConnection.address`**; AppRole auth enabled; **`vaultAuthGlobal.appRole.roleId`** matches your Vault role.
3. **Per-consumer namespaces** — create or replicate a **`Secret`** named **`vaultAuth.appRole.secretRef`** (default **`vault-approle-secret-id`**) with **`stringData.id`** (or **`data.id`**) set to the AppRole secret ID. Optionally extend **[`acm-hub-vault-credential-sync`**](../acm-hub-vault-credential-sync) so the hub Secret includes an **`id`** key (same value as **`secretId`**) and **`secretKeys`** lists **`id`**, or use a second Policy for a VSO-dedicated Secret name.

## Referencing auth from other namespaces

On each **`VaultStaticSecret`**, set:

```yaml
spec:
  vaultAuthRef: vault-secrets-operator/vault-auth
```

(adjust if you change **`operatorNamespace`** or **`vaultAuth.name`**). **`allowedNamespaces`** on **`VaultAuthGlobal`** and **`VaultAuth`** defaults to **`["*"]`**; tighten in your environment values.

## Legacy Kubernetes auth

Set **`vaultHubConfiguration.vaultAuthGlobal.enabled: false`** to render the previous **Kubernetes**-method **`VaultAuth`** plus **`ServiceAccount`** in the operator namespace (no **`VaultAuthGlobal`**). **`VaultStaticSecret`** would then use a same-namespace **`VaultAuth`** (not the global pattern).

## Hub values

Configured via **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`** under **`vaultHubConfiguration`** (see [`values.yaml`](values.yaml)).

Enable the Application from **`hub-clusters/day2/managed-applications`** by setting **`vaultHubConfiguration.enabled: true`** in that hub environment file.

## Related

- Tekton pipeline Vault env: **`tektonZtp.vault.secretName`** — often the replicated Secret in **`openshift-pipelines`** (see **`acm-hub-vault-credential-sync`**).
- ZTP **`VaultStaticSecret`**: [`cluster-automation/ztp-spoke/README.md`](../../../../cluster-automation/ztp-spoke/README.md)
