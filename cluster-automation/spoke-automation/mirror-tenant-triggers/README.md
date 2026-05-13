# Chart: mirror-tenant-triggers

Tekton Triggers (EventListener, TriggerBinding, TriggerTemplate) that start pipeline `ocp-registry-mirror` when an HTTP POST arrives. Tenants supply an `ImageSetConfiguration` via a ConfigMap in `openshift-pipelines`.

## Enable

Set `tenantMirrorTriggers.enabled: true` in both `managed-applications/values.yaml` (renders the ArgoCD Application) and the hub `hub-env-values/.../values.yaml` (renders the Tekton resources).

## HTTP payload

`POST` to the EventListener service with:
```json
{
  "destRegistry": "docker://quay.example/ocp-mirror",
  "imagesetConfigMap": "tenant-a-imageset-cm",
  "skipGitSync": "false"
}
```
`destRegistry` and `imagesetConfigMap` are required; the CEL interceptor rejects requests missing either.

## Local render

```bash
helm template tekton-mirror-tenant-triggers ./cluster-automation/spoke-automation/mirror-tenant-triggers \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
