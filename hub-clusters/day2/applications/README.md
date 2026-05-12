# Hub Day 2 workload charts (`hub-clusters/day2/applications/`)

Only **Helm charts** that child OpenShift GitOps `Application` resources point at live here (operator policies, GitOps patch, ZTP namespace, hub platform, etc.).

The **`Application` CRs** that reference these paths are rendered by **`../managed-applications/`** (Helm chart next to this directory). Hub identity for **`helm.valueFiles`** → **`../hub-env-values/...`** is set in **`../managed-applications/values.yaml`**.

## Charts

| Directory | Role |
|-----------|------|
| `operator-installations/` | OperatorPolicy chart (OpenShift GitOps, OpenShift Pipelines, and other operators on the hub). |
| `gitops-repos-config/` | `VaultStaticSecret` resources for Argo CD ↔ Git (Vault-sourced credentials). |
| `policy-generator-gitops-patch/` | Argo CD repo-server patch for PolicyGenerator. |
| `ztp-configuration/` | `ztp-common` (or configured) namespace on the hub. |
| `ztp-disconnected-configuration/` | Disconnected hub: `OperatorHub`, mirrored `CatalogSource`, mirror `ConfigMap` with IDMS/ITMS YAML for Assisted Installer / ZTP (not IDMS/ITMS cluster CRs on the hub). |
| `hub-platform-day2/` | Optional hub proxy, trusted CA, API / ingress certificates. |
| `vault-hub-configuration/` | **`VaultConnection`**, **`VaultAuthGlobal`**, and **`VaultAuth`** for Vault Secrets Operator on the hub. |

## Related

- Child `Application` templates: [../managed-applications/README.md](../managed-applications/README.md)
- Shared per-hub values: [../hub-env-values/README.md](../hub-env-values/README.md)
