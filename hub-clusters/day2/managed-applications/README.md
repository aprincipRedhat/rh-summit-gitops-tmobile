# Managed Applications

Helm chart that renders all child ArgoCD `Application` CRs consumed by **`root-day2-applications`**.

Set `hub.environment`, `hub.site`, `hub.clusterName` in `values.yaml` to select the matching `hub-env-values/.../values.yaml` for every child Application.

## Key toggles (in `values.yaml`)

| Key | Effect |
|-----|--------|
| `acmDay1.enabled` | Renders `app-acm-day1` (adopts Day 1 resources into Argo). |
| `acmPolicies.enabled` | Renders `app-acm-policies-<clusterName>` pointing at `spoke-clusters/.../policies`. |
| `tektonNodeReplacement.enabled` | Renders `app-tekton-node-replacement` (legacy; prefer integrated replacement in `ztp-pipeline`). |
| `tenantMirrorTriggers.enabled` | Renders `app-tekton-mirror-tenant-triggers`. |
| `vaultHubConfiguration.enabled` | Renders `app-vault-hub-configuration` (`VaultConnection`, `VaultAuth`). |
| `vaultHubCredentialSync.enabled` | Renders `app-acm-hub-vault-credential-sync` (hub Policy replicating Vault credentials). |

## Application index

| Template | `spec.source.path` |
|----------|--------------------|
| `application-acm-day1.yaml` | `hub-clusters/day1/acm-day1` |
| `application-acm-spoke-clusters.yaml` | `hub-clusters/day2/applications/acm-spoke-clusters` |
| `application-operator-installations.yaml` | `hub-clusters/day2/applications/operator-installations` |
| `application-policy-generator-gitops-patch.yaml` | `hub-clusters/day2/applications/policy-generator-gitops-patch` |
| `application-ztp-configuration.yaml` | `hub-clusters/day2/applications/ztp-configuration` |
| `application-ztp-disconnected-configuration.yaml` | `hub-clusters/day2/applications/ztp-disconnected-configuration` |
| `application-gitops-repos-config.yaml` | `hub-clusters/day2/applications/gitops-repos-config` |
| `application-hub-platform-day2.yaml` | `hub-clusters/day2/applications/hub-platform-day2` |
| `application-vault-hub-configuration.yaml` | `hub-clusters/day2/applications/vault-hub-configuration` |
| `application-acm-hub-vault-credential-sync.yaml` | `hub-clusters/day2/applications/acm-hub-vault-credential-sync` |
| `application-tekton-ztp.yaml` | `cluster-automation/spoke-automation/ztp-pipeline` |
| `application-tekton-bulk-ztp.yaml` | `cluster-automation/spoke-automation/bulk-ztp-pipeline` |
| `application-tekton-mirror.yaml` | `cluster-automation/spoke-automation/mirror-pipeline` |
| `application-tekton-mirror-tenant-triggers.yaml` | `cluster-automation/spoke-automation/mirror-tenant-triggers` |
| `application-tekton-node-replacement.yaml` | `cluster-automation/spoke-automation/ztp-node-replacement` |
| `application-acm-policies.yaml` | `spoke-clusters/.../policies` (Kustomize, from `hub.*`) |

```bash
helm template mgd ./hub-clusters/day2/managed-applications -f hub-clusters/day2/managed-applications/values.yaml
```
