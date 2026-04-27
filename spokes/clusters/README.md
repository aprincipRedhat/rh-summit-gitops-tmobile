# Spokes Clusters Output

## Purpose

This folder is generated output.

The ZTP pipeline (hub chart `hub/day2/helm/ztp-pipeline`) writes:

- `spokes/clusters/<cluster-name>/manifests.yaml`

OpenShift GitOps **ApplicationSet** from [hub/day2/gitops/bootstrap](../../hub/day2/gitops/bootstrap/README.md) watches `spokes/clusters/*` by default (`clustersPath` in bootstrap `values.yaml`) and syncs each folder to the hub.
