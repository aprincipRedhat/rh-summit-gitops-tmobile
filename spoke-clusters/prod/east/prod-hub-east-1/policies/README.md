# Spoke policies — prod-hub-east-1

PolicyGenerator + Kustomize for RHACM governance on hub `prod-hub-east-1`.

- `common-gitops-config-pg.yaml` — `ArgoCD` resource tuning (disabled by default; set `disabled: false` to apply).
- `common-operatorpolicy-pg.yaml` — `OperatorPolicy` installs; subscription pins resolved from `ztp-common` ConfigMap.
- Source CRs: `../../../../../source-crs/` (load restrictions disabled via `policy-generator-gitops-patch`).

ArgoCD Application `app-acm-policies-prod-hub-east-1` syncs this directory into namespace `policies`.

```bash
kustomize build --enable-alpha-plugins spoke-clusters/prod/east/prod-hub-east-1/policies
```
