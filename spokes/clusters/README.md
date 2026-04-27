# Rendered spoke manifests (Git)

The ZTP OpenShift Pipelines pipeline writes **`manifests.yaml`** under `spokes/clusters/<clusterName>/` and opens a pull request. OpenShift GitOps **ApplicationSet** (from **`hub/day2/gitops/bootstrap`**) watches **`spokes/clusters/*`** by default.

This directory is intentionally empty in source control until the pipeline runs.
