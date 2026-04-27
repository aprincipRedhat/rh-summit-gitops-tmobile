# Spoke cluster automation

Artifacts used when provisioning or configuring spokes from the hub.

| Path | Role |
|------|------|
| [`helm/ztp-spoke`](helm/ztp-spoke) | Helm chart: **ClusterInstance**, spoke **Namespace**, optional **`ztp-common`** per-cluster **ConfigMap** (`clusterValues.data`). Values come from **[`../pipeline-values`](../pipeline-values)** (`**/pipeline-values/<cluster>.yaml`); OCP Pipelines uses `ztpChartRelativePath` in `hub/day2/helm/tekton-ztp-pipeline` and `tekton-bulk-ztp-pipeline`. |
| [`../policies`](../policies) | **PolicyGenerator** + Kustomize: example RHACM policies (including **Placement** on **`common: "true"`** and optional Pipelines pin from hub ConfigMaps). |
