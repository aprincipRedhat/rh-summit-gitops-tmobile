# `hub-env-values` — per-hub Helm values

One file per hub: `hub-clusters/day2/hub-env-values/<environment>/<site>/<hub-cluster-name>/values.yaml`

Each file is a small override layer on top of chart defaults. Set `hub.environment`, `hub.site`, and `hub.clusterName` in `managed-applications/values.yaml` to select the right file for every child Application.

## Top-level keys

| Key | Chart |
|-----|-------|
| `operators.openshiftGitOps` / `operators.openshiftPipelines` | `operator-installations` — channel / CSV pins. |
| `mce`, `acm`, `multiClusterHub`, `vaultSecretsOperator`, `vaultBootstrap` | `acm-day1` (via `acmDay1.enabled`). |
| `tektonZtp` | `ztp-pipeline` — images, vault secret name, pipeline defaults. |
| `tektonBulkZtp` | `bulk-ztp-pipeline` — `childDefaults.manifestOutputDir`. |
| `tektonMirror` | `mirror-pipeline` — `mirrorImage`, `imageSetConfiguration`, `gitSync` targets. |
| `ztpDisconnected` | `ztp-disconnected-configuration` — `OperatorHub`, mirrored `CatalogSource`, IDMS/ITMS for mirror `ConfigMap`. |
| `hubPlatform` | `hub-platform-day2` — proxy, trusted CA, named certs, ingress controller. |
| `gitopsReposConfig` | `gitops-repos-config` — `VaultStaticSecret` entries for Argo Git credentials. |

`manifestOutputDir` and `ztpChartRelativePath` under `tektonZtp` / `tektonBulkZtp` must point to the correct `spoke-clusters/<env>/<site>/<hub>/clusters/` path for that hub.
