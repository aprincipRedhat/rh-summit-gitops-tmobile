# Spoke Policies

## Purpose

PolicyGenerator + Kustomize source for RHACM governance policies.

## Outputs

- `Policy`
- `Placement`
- `PlacementBinding`

## Requirements

- ManagedClusters should have expected labels (for example `common: "true"`).
- PolicyGenerator plugin must be available where Kustomize runs.
- For OpenShift GitOps repo-server usage, apply the patch in:
  - `../../hub/day2/gitops/policy-generator-plugin/README.md`

## Build

```bash
cd spokes/policies
kustomize build --enable-alpha-plugins .
```
