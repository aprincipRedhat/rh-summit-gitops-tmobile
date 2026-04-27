# Pipeline Values

## Purpose

Per-cluster values files used by the ZTP pipeline and `ztp-spoke` chart.

## Inputs

`**/pipeline-values/<cluster-name>.yaml`

The pipeline resolves exactly one file for the `cluster-name` parameter.

In this repo, files live under **`spokes/pipeline-values/`** (for example `spokes/pipeline-values/dev/east/pipeline-values/<cluster>.yaml`). The hub ZTP chart is **`hub/day2/helm/ztp-pipeline`**.

## Examples

- `spokes/pipeline-values/dev/east/pipeline-values/dev-east-us-1.yaml`
- `spokes/pipeline-values/prod/east/pipeline-values/prod-east-us-1.yaml`
