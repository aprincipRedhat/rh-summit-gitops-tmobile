# Backlog

- **PR checks** — `helm lint` / `helm template` on `ztp-spoke` + `kustomize build` on `policies/` in GitHub Actions.
- **Validate script** — wrap Day 1/Day 2 `helm template` one-liners and policy builds into `make ci` or `./scripts/validate.sh`.
- **Tenant mirror triggers** — enable `tenantMirrorTriggers.enabled` in `managed-applications` + `hub-env-values` when ready (chart already present at `cluster-automation/spoke-automation/mirror-tenant-triggers`).
- **Hub drift checks** — diff top-level keys between `dev` and `prod` hub-env-values or add JSON Schema once the shape settles.
- **Image pinning** — Renovate/Dependabot on `custom-container-images` if tags are bumped often.
