# `99-pipeline-values` (prod hub)

Per-spoke YAML inputs for **`helm template`** against **`cluster-automation/ztp-spoke`**.

## Convention

Exactly one file per cluster:

```text
spoke-clusters/prod/east/prod-hub-east-1/99-pipeline-values/<spoke-cluster-name>.yaml
```

The ZTP Tekton pipeline searches for **`**/99-pipeline-values/<cluster-name>.yaml`** and fails if zero or multiple matches exist.

## Example

- `prod-east-us-1.yaml` — values for cluster **`prod-east-us-1`**.

See also [../../../../../README.md](../../../../../README.md) (repository) and [../../../../README.md](../../../../README.md) (`spoke-clusters/`).
