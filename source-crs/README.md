# Shared PolicyGenerator source CRs

Canonical YAML used by PolicyGenerator manifests under `spoke-clusters/<env>/<site>/<hub>/policies/`. One catalog for all hubs; hub-specific values are applied via `manifests[].patches` in each `*-pg.yaml`.

Path from `policies/kustomization.yaml`: `../../../../../source-crs/<file>.yaml`

`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true` (set via `policy-generator-gitops-patch`) allows these paths to resolve outside the `policies/` directory.

## Files wired to PolicyGenerator

| File | Notes |
|------|-------|
| `generic-operatorpolicy.yaml` | Placeholder names; patch-merge target for `common-operatorpolicy-pg.yaml`. |
| `generic-argocd-instance-resources.yaml` | `${SERVER_*}` / `${APPLICATIONSET_*}` resource limits — overridden via patches when the policy is enabled. |

## Generic stubs (extend as needed)

`generic-namespace.yaml`, `generic-configmap.yaml`, `generic-secret.yaml`, `generic-machineconfig.yaml`, `generic-serviceaccount.yaml`, `generic-role.yaml`, `generic-rolebinding.yaml`, `generic-clusterrolebinding.yaml`, `generic-service.yaml`, `generic-persistentvolumeclaim.yaml`, `generic-networkpolicy.yaml`, `generic-subscription.yaml`, `generic-imagedigestmirrorset.yaml`, `generic-imagetagmirrorset.yaml`

Use `${VAR}` tokens with `envsubst` or PolicyGenerator `patches` to substitute values.
