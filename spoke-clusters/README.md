# Spoke clusters (`spoke-clusters/`)

```
spoke-clusters/<env>/<site>/<hub>/
  policies/                             # Kustomize + PolicyGenerator
  99-pipeline-values/<cluster>.yaml     # ZTP pipeline input
  clusters/<cluster>/manifests.yaml     # pipeline output (ArgoCD watches this)
```

Shared PolicyGenerator manifests: `source-crs/` at repo root (paths in `policies/kustomization.yaml` use `../../../../../source-crs/...`).

## GitOps wiring

- **Policies** — ArgoCD `app-acm-policies-<hub>` points at `spoke-clusters/.../policies` (Kustomize).
- **Rendered manifests** — `ApplicationSet spoke-cluster-gitops-apps` watches `spoke-clusters/*/*/*/clusters` so each `clusters/<spoke>/` becomes a sync target.

`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true` is set via `policy-generator-gitops-patch` so PolicyGenerator can resolve `source-crs/` paths outside the `policies/` directory.

## Policy files

- `common-gitops-config-pg.yaml` — `ArgoCD` instance config policy.
- `common-operatorpolicy-pg.yaml` — `OperatorPolicy` installs; subscription pins resolve from the `ztp-common` ConfigMap written by `ztp-spoke`.
