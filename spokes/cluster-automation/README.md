# Spoke Cluster Automation

## Purpose

Contains spoke-side templating inputs used by hub pipelines.

## Key Paths

| Path | Purpose |
|------|---------|
| `helm/ztp-spoke/` | Helm chart for `ClusterInstance`, namespace, and optional shared config. |
| `../pipeline-values/` | Per-cluster values files consumed by the ZTP pipeline. |
| `../policies/` | Optional RHACM policies applied to managed clusters. |
