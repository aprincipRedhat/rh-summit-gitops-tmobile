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

## Repository layout

- Chart directory: `hub/day2/helm/bulk-ztp-pipeline/`.
- Hub values: `hub/hub-values/.../<hub>.yaml` (same `-f ../../../hub-values/...` pattern as other Day 2 charts).
- OpenShift GitOps: [application-tekton-bulk-ztp.yaml](../../gitops/managed-applications/application-tekton-bulk-ztp.yaml) — `path: hub/day2/helm/bulk-ztp-pipeline`, `releaseName: tekton-bulk-ztp-pipeline`.

## Apply

```bash
helm template tekton-bulk-ztp-pipeline . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```
