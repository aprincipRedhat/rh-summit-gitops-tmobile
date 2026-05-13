# Chart: bulk-ztp-pipeline

Tekton Pipeline that lists ACM `ManagedCluster` objects and starts child `ztp-cluster-render-pr` PipelineRuns with bounded concurrency.

## Parameters

- `dry-run=true` — prints which clusters would run without creating PipelineRuns.
- `child-run-*` / `child-skip-*` — forwarded to each child ZTP PipelineRun (mirrors `ztp-pipeline` params).
- `max-concurrent` — max simultaneous child PipelineRuns per wave.

## Hub values (`tektonBulkZtp`)

Set `childDefaults.manifestOutputDir` and `ztpChartRelativePath` to match the hub's `spoke-clusters/.../clusters/` layout.

## Local render

```bash
helm template tekton-bulk-ztp-pipeline ./cluster-automation/spoke-automation/bulk-ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
