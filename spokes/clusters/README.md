# Spokes Clusters Output

## Purpose

This folder is generated output.

The ZTP pipeline writes:

- `spokes/clusters/<cluster-name>/manifests.yaml`

OpenShift GitOps `ApplicationSet` watches `spokes/clusters/*` and syncs each folder.
