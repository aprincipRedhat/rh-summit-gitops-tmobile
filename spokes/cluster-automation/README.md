# Spoke Cluster Automation

## Purpose

Contains spoke-side templating inputs used by hub pipelines.

## Key Paths

| Path | Purpose |
|------|---------|
| `helm/ztp-spoke/` | Helm chart for `ClusterInstance`, namespace, and optional shared config. |
| `../pipeline-values/` | Per-cluster values files consumed by the hub chart `hub/day2/helm/ztp-pipeline`. |
| `../policies/` | Optional RHACM policies applied to managed clusters. |
| Hub bulk chart | `hub/day2/helm/bulk-ztp-pipeline` runs child `PipelineRun`s against the ZTP pipeline above. |
