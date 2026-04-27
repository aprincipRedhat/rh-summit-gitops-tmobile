# Chart: bulk-ztp-pipeline

## Purpose

Creates a bulk Tekton pipeline that:

- Lists `ManagedCluster` resources.
- Filters by label/exclude list.
- Starts ZTP child `PipelineRun`s in waves.
- Waits for each wave and stops on failures.

## Inputs

- Hub values: `tektonBulkZtp.*`
- Target pipeline usually `ztp-cluster-render-pr`

## Apply

```bash
helm template tekton-bulk-ztp-pipeline . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```
