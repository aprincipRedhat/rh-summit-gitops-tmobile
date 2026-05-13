# Chart: ztp-spoke

Helm chart rendered by the ZTP pipeline: outputs `Namespace`, `ClusterInstance`, optional `ztp-common` ConfigMap, and `VaultStaticSecret` resources for BMC / pull secret into `cluster.namespace`.

## Key values

| Key | Role |
|-----|------|
| `cluster` | Cluster identity and target namespace. |
| `pullSecretRef` | Assisted Installer pull secret name. |
| `clusterNetworking` | `ClusterInstance.spec` network config (cluster/service/machine CIDRs). |
| `nodeGroups` | `masters` / `workers` hostname lists; expanded to `nodes[]` by the pipeline. |
| `nodes` | Full node entries with MACs (pipeline-merged, or static for clusters skipping discovery). |
| `clusterDefaults` | Shared `rootDeviceHints`, `nicMappings` (per-role `logicalName` + `redfishMemberMatch`). |
| `bmcAddressTemplate` | Redfish URL pattern per host (`{hostname}` substituted). |
| `vault` | `enabled`, `vaultAuthRef`, KV paths for BMC + pull secret `VaultStaticSecret`. |
| `nodeReplacement.omitMarkedNodes` | Omit nodes with `replacementTarget: true` from `ClusterInstance.spec.nodes` (suppress phase). |

## Local render

```bash
# Merge base values + discovered nodes, expand nodeGroups, then render
python3 cluster-automation/spoke-automation/ztp-pipeline/files/scripts/merge_pipeline_values.py \
  spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/dev-east-us-1.yaml \
  discovered-nodes.yaml /tmp/merged.yaml

python3 cluster-automation/spoke-automation/ztp-pipeline/files/scripts/expand_node_inventory.py \
  /tmp/merged.yaml

helm template dev-east-us-1 ./cluster-automation/ztp-spoke -f /tmp/merged.yaml
```
