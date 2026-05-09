# `99-pipeline-values` (dev hub)

Per-spoke YAML inputs for **`helm template`** against **`cluster-automation/ztp-spoke`**.

## Convention

Exactly one file per cluster:

```text
spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/<spoke-cluster-name>.yaml
```

The ZTP Tekton pipeline searches for **`**/99-pipeline-values/<cluster-name>.yaml`** and fails if zero or multiple matches exist.

## Hostname-only + MAC discovery (recommended)

Define **`nodeHostnames`**, **`clusterNetworking`** (cluster / service / machine networks), **`clusterDefaults`** (**`nicMapping`**, **`rootDeviceHints`**), **`bmcAddressTemplate`**, and **`vault`** (`bmcCredentialsVaultPathPattern`, **`assistedDeployment.pullSecret.vaultPath`**). Do **not** check in static MAC addresses — Tekton Ansible merges **`nodes`** from Redfish before **`helm template`**.

For a local preview, merge with **`discovered-nodes.example.yaml`** (see **[ztp-spoke README](../../../../cluster-automation/ztp-spoke/README.md)**).

## Legacy static `nodes`

You may still commit full **`nodes:`** with **`macAddress`** for clusters that skip discovery; **`run-mac-discovery`** can be set to **`false`** on the PipelineRun.

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
