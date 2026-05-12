# `hub-env-values` — per-hub Helm values

Shared values for hub Day 2 Helm charts, keyed by **`hub-clusters/day2/hub-env-values/<environment>/<site>/<hub-cluster-name>/values.yaml`**.

Each file in this tree is a **small override layer**: operator pins, vault bootstrap placeholders, hub-specific Tekton paths (`manifestOutputDir`, mirror `gitSync` targets), and similar site facts. Broader defaults (`hubPlatform`, full `tektonZtp` blocks, `ztpDisconnected`, ACM subscription pins, and so on) live in the **leaf Application chart** `values.yaml` files and merge with these overrides at render time.

## Examples in this repo

- `dev/east/dev-hub-east-1/values.yaml`
- `prod/east/prod-hub-east-1/values.yaml`

## Consumption

Child Applications are rendered by **`hub-clusters/day2/managed-applications`** (Helm). Set **`hub.environment`**, **`hub.site`**, and **`hub.clusterName`** in that chart’s **`values.yaml`** so every workload chart receives the matching file below via **`helm.valueFiles`**.

Paths in each child `Application` remain **relative to that chart’s `spec.source.path`**. Examples:

- From `hub-clusters/day2/applications/operator-installations`: `../../hub-env-values/<environment>/<site>/<hub-cluster-name>/values.yaml`
- From `hub-clusters/day1/acm-day1`: `../../day2/hub-env-values/<environment>/<site>/<hub-cluster-name>/values.yaml`
- From `cluster-automation/spoke-automation/ztp-pipeline`: `../../../hub-clusters/day2/hub-env-values/<environment>/<site>/<hub-cluster-name>/values.yaml`

## Keys (high level)

- **`operators.openshiftGitOps`**, **`operators.openshiftPipelines`** — channels / CSV pins for the hub OperatorPolicy chart (`operator-installations`).
- **`mce`**, **`acm`**, **`multiClusterHub`**, **`vaultSecretsOperator`**, **`vaultBootstrap`** — ACM Day1 / Vault bootstrap (**`app-acm-day1`** Argo Application → [`../../day1/acm-day1/README.md`](../../day1/acm-day1/README.md)); only applied when **`acmDay1.enabled`** is set in **`managed-applications/values.yaml`**.
- **`gitopsReposConfig`** — `VaultStaticSecret` entries for **`gitops-repos-config`** (Argo Git credentials via Vault).
- **`ztpConfiguration.namespace`** — target namespace for **`ztp-configuration`** (must match **`ztp-spoke`** pipeline values `ztpCommon.namespace`).
- **`acmSpokeClusters`** — namespaces for **`acm-spoke-clusters`** (`policies`, **`ztp-common`** RBAC target); defaults align with **`ztpConfiguration`**.
- **`ztpDisconnected`** — restricted-network hub (**`ztp-disconnected-configuration`** chart): **`OperatorHub`**, mirrored **`CatalogSource`**, and **`imageDigestMirrorSets`** / **`imageTagMirrorSets`** values rendered into the mirror **`ConfigMap`** for Assisted Installer / ZTP (not as IDMS/ITMS cluster CRs on the hub).
- **`hubPlatform`** — optional proxy, trusted CA, **`hubPlatform.apiServer`** (APIServer `namedCertificates`), and **`hubPlatform.ingressController`** (default router `defaultCertificate`) for `hub-platform-day2`.
- **`tektonZtp`**, **`tektonBulkZtp`**, **`tektonMirror`** — Tekton pipeline charts under `cluster-automation/spoke-automation/` (includes `waitForMerge`, `deployWatch`, and `images.cli` for the ZTP pipeline). **`tektonMirror.gitSync`** drives the mirror pipeline’s PR back into this **`values.yaml`** (**`hub-values-relative-path`**); **`tektonMirror.github`** names the **`GH_TOKEN`** Secret used by **`gh pr create`**. **`tektonMirror.imageSetConfiguration`** (multiline YAML) renders the mirror **`ImageSetConfiguration`** `ConfigMap` (key **`tektonMirror.imagesetConfigMapKey`**, default **`ImageSetConfiguration.yaml`**); set **`tektonMirror.pipeline.mirrorImage`** to your built **`custom-container-images/oc-mirror`** image.

Adjust `manifestOutputDir` and `ztpChartRelativePath` under `tektonZtp` / `tektonBulkZtp` so pipeline commits land under the correct **`spoke-clusters/<env>/<site>/<hub>/clusters/`** tree for that hub.
