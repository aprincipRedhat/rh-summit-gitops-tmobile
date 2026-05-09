# `99-pipeline-values` (dev hub)

Per-spoke YAML inputs for **`helm template`** against **`cluster-automation/ztp-spoke`**.

## Convention

Exactly one file per cluster:

```text
spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/<spoke-cluster-name>.yaml
```

The ZTP Tekton pipeline searches for **`**/99-pipeline-values/<cluster-name>.yaml`** and fails if zero or multiple matches exist.

## Example

- `dev-east-us-1.yaml` — values for cluster **`dev-east-us-1`**.

## Optional keys for ZTP Tekton preflight

Used by **`preflight-sdn`** / **`preflight-network`** tasks when enabled via Pipeline params:

```yaml
sdnValidation:
  healthUrl: "https://example.net/sdn/health"

networkValidation:
  mode: ping   # ping (default behavior with Ansible) | iso — iso fails until customer tooling is wired
```

See [../../../../../cluster-automation/spoke-automation/ztp-pipeline/README.md](../../../../../cluster-automation/spoke-automation/ztp-pipeline/README.md).

See also [../../../../../README.md](../../../../../README.md) (repository) and [../../../../README.md](../../../../README.md) (`spoke-clusters/`).
