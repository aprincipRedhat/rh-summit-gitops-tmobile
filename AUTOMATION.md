# Automation notes

Personal scratchpad for what we’re actually changing in this repo versus what’s still sitting in the backlog. Tekton already does `helm lint` / `helm template` on the hub; GitOps picks up each spoke under `spoke-clusters/.../clusters/<cluster>/`. This file doesn’t repeat that flow—see [cluster-automation/README.md](cluster-automation/README.md).

---

## Plans for future

**Tenant-driven mirror runs.** There’s a Helm chart at `cluster-automation/spoke-automation/mirror-tenant-triggers` (EventListener, bindings, template) that kicks the existing `ocp-registry-mirror` pipeline when a tenant posts payload + ConfigMap. Flip it on from the hub by setting `tenantMirrorTriggers.enabled` in both `hub-clusters/day2/managed-applications/values.yaml` and the matching `hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`—details in that chart’s README.

**Spoke manifests via ApplicationSet.** The day-2 app-of-apps deploys an ApplicationSet that walks `spoke-clusters/*/*/*/clusters/*` so each spoke folder becomes its own Application (namespace = folder name). That’s the spine for rendered ZTP output landing in Git.

**ACM / policy plumbing.** `hub-clusters/day2/applications/acm-spoke-clusters` keeps the `policies` namespace and hub-template RBAC in one place; spokes reference shared stuff under `source-crs/` and hub-specific `policies/` kustomize.

**Disconnected mirror metadata on spokes.** Policy manifests like `spoke-clusters/.../policies/manifests/oc-mirror-idms-itms.yaml` pair with the disconnected hub story (`ztp-disconnected-configuration` catalog + mirror ConfigMap on the hub). Spokes carry IDMS/ITMS; the hub chart documents what stays where.

**Pipeline charts.** Besides ZTP and mirror, we carry bulk-ZTP under `cluster-automation/spoke-automation/`. **Bare-metal node replacement** is folded into **`ztp-pipeline`**: after clone, **`detect-node-replacement`** chooses **`replacement-flow`**; use **`replacementTarget`** on exactly one node in **`99-pipeline-values`**, and enable **`applicationSet.ignoreDifferences`** on the hub ApplicationSet during swaps as before. The standalone **`ztp-node-replacement`** chart and **`app-tekton-node-replacement`** remain optional (**`tektonNodeReplacement.enabled`** in **`managed-applications`** and **`hub-env-values`**).

*(Edit this section when reality diverges—e.g. drop bullets once merged, add the next initiative.)*

**PR checks.** Right now nothing in-repo runs Helm or `kustomize build` on every push. Plan is GitHub Actions (or whatever hosts the remote): `helm lint` / `helm template` on `ztp-spoke` with a real sample values file, and `kustomize build --enable-alpha-plugins .` from each hub `policies/` directory we touch. Optional later: yamllint, kubeconform with a small CRD pack—full OpenShift schema in CI is usually more pain than value.

**One script everyone runs.** Wrap the README `helm template` one-liners plus policy builds into `make ci` or `./scripts/validate.sh` so laptop matches CI and we stop arguing about `-f` paths.

**Catch drift between dev and prod hubs.** Same keys in `99-pipeline-values` and friends—either a cheap shell diff on top-level keys or JSON Schema once the shape settles. Low priority until PR checks exist.

**Images.** Renovate/Dependabot on `custom-container-images` if we start bumping tags often; digest-pin Tekton steps only if we need repro builds more than quiet PRs.

---

## Links

- [README.md](README.md)
- [cluster-automation/README.md](cluster-automation/README.md)
- [spoke-clusters/README.md](spoke-clusters/README.md)
