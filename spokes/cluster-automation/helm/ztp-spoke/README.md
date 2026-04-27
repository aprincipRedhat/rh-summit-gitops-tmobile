# Chart: ztp-spoke

## Purpose

Renders hub-side spoke provisioning resources:

- spoke namespace
- `ClusterInstance`
- optional `ztp-common` ConfigMap per cluster

## Inputs

- No chart-local `values.yaml`.
- Inputs come from `**/pipeline-values/<cluster>.yaml`.
- Usually rendered by Day 2 ZTP pipeline.

## Local Render

```bash
helm template dev-east-us-1 . -f ../../../pipeline-values/dev/east/pipeline-values/dev-east-us-1.yaml
```

## Notes

- Secrets referenced by name must exist out-of-band.
- `templateRefs` must match templates installed on the hub.
