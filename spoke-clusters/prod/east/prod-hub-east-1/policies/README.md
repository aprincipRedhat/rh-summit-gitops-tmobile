# Spoke policies (prod hub)

## Purpose

PolicyGenerator + Kustomize source for RHACM governance policies for hub **`prod-hub-east-1`**.

## Layout

- **`common-gitops-config-pg.yaml`** — **`ArgoCD`** resource tuning from **`source-crs/generic-argocd-instance-resources.yaml`** + **patches** (disabled by default).
- **`common-operatorpolicy-pg.yaml`** — **`OperatorPolicy`** installs from **`source-crs/generic-operatorpolicy.yaml`** (multiple entries + **patches**).
- **`kustomization.yaml`** — **`generators`** only (hub **`policies`** namespace + hub-template RBAC live in **`hub-clusters/day2/applications/acm-spoke-clusters`**). Hub-only Vault credential replication is **`hub-clusters/day2/applications/acm-hub-vault-credential-sync`** — not in this folder.
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

OpenShift GitOps Application **`app-acm-policies-prod-hub-east-1`** syncs **`spoke-clusters/prod/east/prod-hub-east-1/policies`** into namespace **`policies`**.

## Build (local)

From the repository root:

```bash
cd spoke-clusters/prod/east/prod-hub-east-1/policies
kustomize build --enable-alpha-plugins .
```
