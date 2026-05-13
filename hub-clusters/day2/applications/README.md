# Day 2 application charts (`hub-clusters/day2/applications/`)

Helm charts that child ArgoCD `Application` CRs (rendered by `managed-applications/`) point at.

| Directory | Role |
|-----------|------|
| `operator-installations/` | OperatorPolicy — OpenShift GitOps, Pipelines, and other hub operators. |
| `gitops-repos-config/` | `VaultStaticSecret` resources for Argo ↔ Git credentials (Vault-sourced). |
| `policy-generator-gitops-patch/` | Argo repo-server patch enabling PolicyGenerator. |
| `ztp-configuration/` | `ztp-common` namespace on the hub. |
| `ztp-disconnected-configuration/` | Disconnected hub: `OperatorHub`, mirrored `CatalogSource`, IDMS/ITMS mirror `ConfigMap`. |
| `hub-platform-day2/` | Optional proxy, trusted CA, API / ingress certificates. |
| `vault-hub-configuration/` | `VaultConnection`, `VaultAuthGlobal`, `VaultAuth` for Vault Secrets Operator. |
| `acm-spoke-clusters/` | `policies` namespace + hub-template RBAC for `ztp-common` ConfigMaps. |
| `acm-hub-vault-credential-sync/` | Hub-only ACM Policy replicating Vault credentials into labelled namespaces. |
