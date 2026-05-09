# acm-hub-vault-credential-sync

Hub-local RHACM **Policy** that enforces a clone of the Vault bootstrap Secret (`vault-tekton-credentials` by default) in every namespace matched by **`vaultHubCredentialSync.namespaceSelector`**. Source material is read with Policy **hub templates** from **`openshift-config`** (`vault-hub-bootstrap-credentials` by default).

## Enable

1. Sync **`app-acm-spoke-clusters`** so **`policy-hub-template-lookup`** exists in **`policies`**.
2. Set **`vaultHubCredentialSync.enabled: true`** in **`hub-clusters/day2/managed-applications/values.yaml`** and **`hub-clusters/day2/99-environments/<hub>/values.yaml`**.
3. Replace placeholders in **`vaultHubCredentialSync.bootstrapSecret.stringData`** (or create the Secret in **`openshift-config`** yourself and set **`bootstrapSecret.enabled: false`**).
4. Label target namespaces, for example: **`vault.hashicorp.com/receive-synced-credentials: "true"`** on **`openshift-pipelines`** and **`ztp-common`**.
5. Set **`vaultHubCredentialSync.policyDisabled: false`** when ready to enforce.

## Alignment

- **`tektonZtp.vault.secretName`** should match **`vaultHubCredentialSync.destinationSecretName`**.
- Placement selects **`local-cluster: "true"`** only.
