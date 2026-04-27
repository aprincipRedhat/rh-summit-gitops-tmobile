# Chart: tekton-mirror-pipeline

## Purpose

Creates the Tekton `oc mirror` pipeline and RBAC in `openshift-pipelines`.

## Inputs

- Runner image from `hub/day2/images/oc-mirror`
- `imageset` workspace (ConfigMap input)
- `registry-auth` workspace (dockerconfig secret)
- Hub values under `tektonMirror.*`

## Apply

```bash
helm template tekton-mirror . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Next

Build and publish the runner image, then set `tektonMirror.pipeline.mirrorImage` in hub values.
