# Spoke policies (prod hub)

## Purpose

PolicyGenerator + Kustomize source for RHACM governance policies for hub **`prod-hub-east-1`**.

## Layout

- **`common-operator-install-pg.yaml`** — PolicyGenerator entry for install-phase policies (aggregated output); **`path`** entries reference **`../../../../../source-crs/`** (repository root).
- **`common-operator-config-pg.yaml`** — PolicyGenerator entry for configuration-phase policies (aggregated output); same shared **`source-crs/`** pattern.
- **`kustomization.yaml`** — references both generators and static `manifests/` resources (not PolicyGenerator-sourced).
- **`../../../../../source-crs/`** — shared catalog at repo root (see **`source-crs/README.md`**).

## Outputs

- `Policy`
- `Placement`
- `PlacementBinding`

## Requirements

- ManagedClusters should carry labels expected by **`placement`** (for example `common: "true"`).
- PolicyGenerator plugin must be available where Kustomize runs.
- For OpenShift GitOps repo-server usage, sync **`hub-clusters/day2/applications/policy-generator-gitops-patch`** via Application **`app-policy-generator-gitops-patch`** (see chart README).

## GitOps

OpenShift GitOps Application **`app-acm-policies-prod-hub-east-1`** syncs **`spoke-clusters/prod/east/prod-hub-east-1/policies`** into namespace **`policies`**.

## Build (local)

From the repository root:

```bash
cd spoke-clusters/prod/east/prod-hub-east-1/policies
kustomize build --enable-alpha-plugins .
```
