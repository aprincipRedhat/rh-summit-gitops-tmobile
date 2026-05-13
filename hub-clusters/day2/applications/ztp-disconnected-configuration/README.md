# Chart: `ztp-disconnected-configuration`

Declarative **hub** configuration for a **restricted-network** OpenShift cluster used with **ZTP**: mirrored **OLM** catalogs and (optionally) **OperatorHub** defaults. Matches Red Hat guidance for [disconnected environments](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/disconnected_environments/index) and [OLM on restricted networks](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/disconnected_environments/olm-restricted-networks).

This chart does **not** replace **`oc mirror`** — it applies selected hub objects you typically promote after mirroring.

## What it can render

| Resource | Purpose |
|----------|---------|
| **`OperatorHub`** (`cluster`) | **`spec.disableAllDefaultSources`** — stop using built-in remote CatalogSources when only mirrored catalogs are reachable. |
| **`CatalogSource`** | Point OLM at your **mirrored** `…-operator-index` image (`spec.sourceType: grpc`). |
| **`ConfigMap`** | When **`ztpDisconnected.configMap.enabled`**, emits **`ImageDigestMirrorSets.yaml`** and **`ImageTagMirrorSets.yaml`** data keys (multi-doc YAML) built from **`imageDigestMirrorSets`** / **`imageTagMirrorSets`** values — for **Assisted Installer disconnected ZTP** and similar flows that consume mirror definitions from a **`ConfigMap`** instead of applying **`ImageDigestMirrorSet`** / **`ImageTagMirrorSet`** CRs on the hub. |

**ImageDigestMirrorSet** and **ImageTagMirrorSet** are **not** reconciled as cluster CRs from this chart; mirror routing on spokes uses policies / spoke manifests as appropriate.

Create **pull secrets** for private mirrors outside this chart — reference them from **`CatalogSource.spec.secrets`** as in OLM docs.

## Values (`ztpDisconnected`)

Set under **`hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`**:

- **`enabled`** — master switch.
- **`operatorHub.enabled`** / **`disableAllDefaultSources`** — cluster **`OperatorHub`**.
- **`imageDigestMirrorSets`** / **`imageTagMirrorSets`** — lists for **`ConfigMap`** YAML keys only (when **`configMap.enabled`**).
- **`catalogSources`** — list of `{ name, namespace?, spec }` (**`spec`** is the **`CatalogSource.spec`** body).
- **`configMap`** — name/namespace for the mirror-artifacts **`ConfigMap`**.

The **`oc mirror`** Tekton pipeline can merge **`oc mirror`** output into **`hub-env-values`** **`ztpDisconnected`**; enable **`configMap`** so the **`ConfigMap`** carries **`ImageDigestMirrorSets.yaml`** / **`ImageTagMirrorSets.yaml`** for disconnected installs.

## GitOps

Application: **`app-ztp-disconnected-configuration`** → destination **`openshift-config`** (cluster-scoped resources sync regardless; **`CatalogSource`** objects use their **`metadata.namespace`**).

## Local render

```bash
helm template ztp-disc ./hub-clusters/day2/applications/ztp-disconnected-configuration \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml
```

## Related

- Mirror Tekton pipeline: `cluster-automation/spoke-automation/mirror-pipeline/`
- Operator installs (subscriptions): `hub-clusters/day2/applications/operator-installations/`
