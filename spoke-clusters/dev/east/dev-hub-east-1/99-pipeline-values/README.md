# `99-pipeline-values`

One YAML file per cluster: `99-pipeline-values/<cluster-name>.yaml`

The ZTP pipeline resolves `**/99-pipeline-values/<cluster-name>.yaml` — fails if zero or multiple matches exist.

## Inventory

Use `nodeGroups` (recommended) or a flat `nodeHostnames` list. Do not commit static MAC addresses — the pipeline Ansible discovers MACs from Redfish and merges them before `helm template`.

```yaml
nodeGroups:
  masters:
    - hostName: master-0
    - hostName: master-1
    - hostName: master-2
  workers:
    - hostName: worker-0
```

Set `run-mac-discovery=false` on the PipelineRun only if `nodes[]` already include `macAddress`.

## Optional preflight keys

```yaml
sdnValidation:
  healthUrl: "https://example.net/sdn/health"   # used when run-sdn-prechecks=true

networkValidation:
  mode: ping   # ping | iso
```
