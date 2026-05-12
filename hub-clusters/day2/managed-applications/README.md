# Managed Applications (OpenShift GitOps)

Helm chart **`managed-applications`** renders child **`Application`** resources consumed by the root Application **`root-day2-applications`** (`hub-clusters/day2/app-of-apps` → `rootApp.sourcePath`).

## Hub identity and `99-environments`

Edit **`values.yaml`** next to `Chart.yaml` (same directory — checked into Git):

- **`hub.environment`**, **`hub.site`**, **`hub.clusterName`** — select **`hub-clusters/day2/99-environments/<environment>/<site>/<clusterName>/values.yaml`** for every Day 2 Helm child Application (`helm.valueFiles`).
- **`repoURL`** / **`targetRevision`** — should match **`hub-clusters/day2/app-of-apps/values.yaml`** used when bootstrapping the root Application.

The root Application syncs this chart with **`helm.valueFiles: [values.yaml]`** (see `rootApp.helmValueFiles` in app-of-apps).

**ACM Day1 (`app-acm-day1`)** — Set **`acmDay1.enabled: true`** in **`managed-applications/values.yaml`** after OpenShift GitOps and the root Application are running. Subscriptions, **`MultiClusterHub`**, Vault Secrets Operator, and the optional vault bootstrap **`Secret`** are driven from **`hub-clusters/day1/acm-day1`** with **`helm.valueFiles`** pointing at your hub **`99-environments/.../values.yaml`** — use the same **`mce`**, **`acm`**, **`multiClusterHub`**, **`vaultSecretsOperator`**, and **`vaultBootstrap`** keys as in this chart’s **`values.yaml`**. Do not double-apply the same Day1 manifests via **`helm template | oc apply`** while Argo manages them.

**Node replacement Application (legacy)** — Prefer the integrated branch in **`ztp-pipeline`** (`detect-node-replacement` → **`replacement-flow=full`**). To keep the separate **`app-tekton-node-replacement`** chart, set **`tektonNodeReplacement.enabled: true`** in **`managed-applications/values.yaml`** so the Application and its **`Pipeline`** CR render.

## ACM policies Application

**`acmPolicies.enabled`** controls rendering of **`app-acm-policies-<clusterName>`**, with `spec.source.path: spoke-clusters/<hub...>/policies` (Kustomize at that path, not this chart). Set **`acmPolicies.enabled: false`** if you manage policy Applications elsewhere.

**`app-acm-spoke-clusters`** deploys hub prerequisites for those policies (`policies` namespace and Policy hub-template RBAC for **`ztp-common`** ConfigMaps). Sync it before or with **`app-acm-policies-*`**.

## Vault hub configuration

Order of operations:

1. **Day 1** — Either apply **`vault-bootstrap-credentials`** via manual **[`acm-day1`](../../day1/acm-day1/README.md)** (`vaultBootstrap`) with real **`VAULT_*`** / **`secretId`** values, **or** enable **`acmDay1`** in **`managed-applications`** after GitOps is running so Argo applies the same chart (see Day1 README). If you already used **`helm template | oc apply`** for **`acm-day1`**, enable **`acmDay1.enabled`** next so Argo adopts those resources and enforces Git state.
2. **`vaultHubConfiguration.enabled: true`** — syncs **`app-vault-hub-configuration`** (**`VaultConnection`**, **`VaultAuthGlobal`**, **`VaultAuth`**).
3. **`vaultHubCredentialSync.enabled: true`** — syncs **`app-acm-hub-vault-credential-sync`**, which applies a **hub-only** **`Policy`** (**`local-cluster`** placement) reading canonical **`vault-hub-bootstrap-credentials`** in **`openshift-config`** and enforcing **`vault-tekton-credentials`** in every namespace that matches **`vaultHubCredentialSync.namespaceSelector`** (label namespaces such as **`openshift-pipelines`** and **`ztp-common`**). Requires **`app-acm-spoke-clusters`** ( **`policy-hub-template-lookup`** ). Set **`vaultHubCredentialSync.policyDisabled: false`** when ready to enforce.
4. **Tekton** — Pipeline Ansible reads **`tektonZtp.vault.secretName`** (defaults to **`vault-tekton-credentials`**) in **`openshift-pipelines`**.

## BO2299 deck parity (slides 17–30)

Implemented in-repo: **`oc-mirror`** promotes IDMS/ITMS into hub **`ztpDisconnected`** values **and** **`policies/manifests/oc-mirror-idms-itms.yaml`**; optional **Tekton Triggers** tenant listener (**`tenantMirrorTriggers.enabled`** on **`managed-applications`**); ZTP pipeline **RUN_\*** preflight/post-deploy/**kube-burner**/manual gate; bulk **`dry-run`** + child passthrough; node replacement pipeline (**`app-tekton-node-replacement`**, **`replacementTarget`** + **`applicationSet.ignoreDifferences`** during swaps — see **`ztp-node-replacement`** README). Scripted etcd removal stays operator-runbook territory.

## Index (templates)

| Template | `spec.source.path` | Child chart `releaseName` |
|----------|-------------------|---------------------------|
| `application-acm-day1.yaml` | `hub-clusters/day1/acm-day1` | `acm-day1` |
| `application-acm-spoke-clusters.yaml` | `hub-clusters/day2/applications/acm-spoke-clusters` | `acm-spoke-clusters` |
| `application-operator-installations.yaml` | `hub-clusters/day2/applications/operator-installations` | `operator-installations` |
| `application-policy-generator-gitops-patch.yaml` | `hub-clusters/day2/applications/policy-generator-gitops-patch` | `policy-generator-gitops-patch` |
| `application-ztp-configuration.yaml` | `hub-clusters/day2/applications/ztp-configuration` | `ztp-configuration` |
| `application-ztp-disconnected-configuration.yaml` | `hub-clusters/day2/applications/ztp-disconnected-configuration` | `ztp-disconnected-configuration` |
| `application-gitops-repos-config.yaml` | `hub-clusters/day2/applications/gitops-repos-config` | `gitops-repos-config` |
| `application-hub-platform-day2.yaml` | `hub-clusters/day2/applications/hub-platform-day2` | `hub-platform-day2` |
| `application-tekton-ztp.yaml` | `cluster-automation/spoke-automation/ztp-pipeline` | `tekton-ztp-pipeline` |
| `application-tekton-node-replacement.yaml` | `cluster-automation/spoke-automation/ztp-node-replacement` | `tekton-node-replacement-pipeline` |
| `application-tekton-bulk-ztp.yaml` | `cluster-automation/spoke-automation/bulk-ztp-pipeline` | `tekton-bulk-ztp-pipeline` |
| `application-tekton-mirror.yaml` | `cluster-automation/spoke-automation/mirror-pipeline` | `tekton-mirror-pipeline` |
| `application-tekton-mirror-tenant-triggers.yaml` | `cluster-automation/spoke-automation/mirror-tenant-triggers` | `tekton-mirror-tenant-triggers` |
| `application-acm-policies.yaml` | `spoke-clusters/.../policies` (from `hub.*`) | n/a (Kustomize) |
| `application-vault-hub-configuration.yaml` | `hub-clusters/day2/applications/vault-hub-configuration` | `vault-hub-configuration` |
| `application-acm-hub-vault-credential-sync.yaml` | `hub-clusters/day2/applications/acm-hub-vault-credential-sync` | `acm-hub-vault-credential-sync` |

## Local render

```bash
helm template mgd ./hub-clusters/day2/managed-applications -f hub-clusters/day2/managed-applications/values.yaml
```

See also [../99-environments/README.md](../99-environments/README.md) for what belongs in the per-hub `values.yaml` file.
