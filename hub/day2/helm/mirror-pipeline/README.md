# Chart: mirror-pipeline

## Purpose

Creates the Tekton `oc mirror` pipeline and RBAC in `openshift-pipelines`.

## Inputs

- Runner image: build from [hub/day2/images/oc-mirror](../../images/oc-mirror) (directory relative to this chart: `../../images/oc-mirror`).
- `imageset` workspace (ConfigMap input)
- `registry-auth` workspace (dockerconfig secret)
- Hub values under `tektonMirror.*`

## Repository layout

- Chart directory: `hub/day2/helm/mirror-pipeline/`.
- OpenShift GitOps: [application-tekton-mirror.yaml](../../gitops/managed-applications/application-tekton-mirror.yaml) — `path: hub/day2/helm/mirror-pipeline`, `releaseName: tekton-mirror-pipeline`.

## Apply

```bash
helm template tekton-mirror-pipeline . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Next

Build and publish the runner image, then set `tektonMirror.pipeline.mirrorImage` in hub values.
