# Hub Values

## Purpose

This folder is the shared configuration source for Day 2 hub Helm apps.

Path format:

`<env>/<site>/hub-values/<hub-cluster>.yaml`

Examples:

- `dev/east/hub-values/dev-hub-east-1.yaml`
- `prod/east/hub-values/prod-hub-east-1.yaml`

## Key Paths

- `hub/day2/helm/ocp-operators-policy`
- `hub/day2/helm/ztp-pipeline`
- `hub/day2/helm/bulk-ztp-pipeline`
- `hub/day2/helm/mirror-pipeline`

## Key Sections

- `operators.*`
- `tektonZtp.*`
- `tektonBulkZtp.*`
- `tektonMirror.*`

Day 2 chart-local `values.yaml` files are intentionally removed.

OpenShift GitOps `Application` resources list these files under `spec.source.helm.valueFiles`; paths are **relative to the chart directory** (`spec.source.path`), for example `../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml` from `hub/day2/helm/ztp-pipeline`. Adjust the file name to match your hub cluster YAML under this tree.
