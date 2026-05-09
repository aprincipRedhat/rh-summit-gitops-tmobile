# Chart: mirror-tenant-triggers

Tekton **Triggers** resources (**EventListener**, **TriggerBinding**, **TriggerTemplate**) that start the shared **`ocp-registry-mirror`** Pipeline with an **`ImageSetConfiguration`** supplied via a **ConfigMap** in **`openshift-pipelines`** (tenant-owned).

## Prerequisites

- OpenShift Pipelines and **Tekton Triggers** installed on the hub.
- Pipeline **`ocp-registry-mirror`** already synced ([mirror-pipeline](../mirror-pipeline)).
- **CEL interceptor** available (default with Triggers).
- Tenants create a **ConfigMap** holding **`ImageSetConfiguration.yaml`** (same key convention as [mirror-pipeline](../mirror-pipeline/README.md)).

## Hub values (`tenantMirrorTriggers` + `tektonMirror`)

Rendered from **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`tenantMirrorTriggers.enabled`** — must be **true** for manifests (also enable the **`app-tekton-mirror-tenant-triggers`** Application via **`hub-clusters/day2/managed-applications`** **`tenantMirrorTriggers.enabled`**).
- **`tektonMirror.gitSync.*`** — defaults for Git PR promotion from **`mirror-pipeline`** (repo slug, hub values path, policy manifest path).
- **`tenantMirrorTriggers.workspaces.sharedStorage`** — PVC size for **`oc mirror`** workspace output.

## HTTP payload

`POST` to the EventListener service/route with JSON body:

```json
{
  "destRegistry": "docker://quay.example/ocp-mirror",
  "imagesetConfigMap": "tenant-a-imageset-cm",
  "skipGitSync": "false",
  "extraFlags": ""
}
```

**Required:** `destRegistry`, `imagesetConfigMap`. Optional params default to empty strings; clients should send **`skipGitSync`: `"false"`** when promoting Git.

The **CEL** filter rejects requests missing **`destRegistry`** or **`imagesetConfigMap`**.

## Security

- Restrict network exposure (cluster-internal **Service** only, **Routes** with OAuth/JWT, or API gateway in front).
- Validate **`allowedDestRegistryPattern`** at the gateway if exposing publicly (not enforced in-chart).

## GitOps

Application template: [`../../../hub-clusters/day2/managed-applications/templates/application-tekton-mirror-tenant-triggers.yaml`](../../../hub-clusters/day2/managed-applications/templates/application-tekton-mirror-tenant-triggers.yaml).

```bash
helm template tekton-mirror-tenant-triggers ./cluster-automation/spoke-automation/mirror-tenant-triggers \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
