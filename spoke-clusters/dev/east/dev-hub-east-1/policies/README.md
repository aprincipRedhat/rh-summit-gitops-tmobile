# Spoke policies (dev hub)

## Purpose

PolicyGenerator + Kustomize source for RHACM governance policies for hub **`dev-hub-east-1`**.

## Layout

- **`common-gitops-config-pg.yaml`** — **`ArgoCD`** resource tuning from **`source-crs/generic-argocd-instance-resources.yaml`** + **patches** (disabled by default — set **`disabled: false`** to roll out).
- **`common-operatorpolicy-pg.yaml`** — **`OperatorPolicy`** installs from **`source-crs/generic-operatorpolicy.yaml`** (multiple entries + **patches**).
- **`kustomization.yaml`** — **`generators`** + static **`resources`** under **`manifests/`** (see **`manifests/README.md`**).
- **`../../../../../source-crs/`** — shared PolicyGenerator inputs at repo root.

## Outputs

- `Policy`
- `Placement`
- `PlacementBinding`

## Requirements

- ManagedClusters should carry labels expected by **`placement`** (for example `common: "true"`).
- PolicyGenerator plugin must be available where Kustomize runs.
- For OpenShift GitOps repo-server usage, sync **`hub-clusters/day2/applications/policy-generator-gitops-patch`** via Application **`app-policy-generator-gitops-patch`** (see chart README).

## GitOps

OpenShift GitOps Application **`app-acm-policies-dev-hub-east-1`** syncs **`spoke-clusters/dev/east/dev-hub-east-1/policies`** into namespace **`policies`**.

## Build (local)

From the repository root:

```bash
cd spoke-clusters/dev/east/dev-hub-east-1/policies
kustomize build --enable-alpha-plugins .
```
