# Chart: ztp-spoke

## Purpose

Helm chart consumed by the ZTP Tekton pipeline: renders **`Namespace`**, **`ClusterInstance`**, optional **`ztp-common`** `ConfigMap`, **`VaultStaticSecret`** objects for BMC + assisted pull secrets, and related hub-side manifests.

## Inputs

Values files live under **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/99-pipeline-values/<cluster-name>.yaml`**.

The pipeline resolves exactly one match for **`**/99-pipeline-values/<cluster>.yaml`** before running:

```bash
helm template "<cluster>" ./cluster-automation/ztp-spoke -f "<effective-values>.yaml"
```

**Hostname-only inventory:** define **`nodeGroups`** (or legacy **`nodeHostnames`**), **`clusterNetworking`**, **`clusterDefaults`** (including **`nicMapping`**), **`bmcAddressTemplate`**, and **`vault`** paths. Tekton Ansible discovers MAC addresses via Redfish and merges a **`nodes`** fragment before `helm template`. For local rendering, merge base values with a discovery fragment (see **`discovered-nodes.example.yaml`** next to the pipeline values file), then run **`expand_node_inventory.py`** when authoring **`nodeGroups`** without a populated **`nodes`** list yet.

**Vault:** when **`vault.enabled`** is true, the chart emits **`VaultStaticSecret`** resources into **`cluster.namespace`**. Set **`vault.vaultAuthRef`** to a **namespaced** reference (for example **`vault-secrets-operator/vault-auth`**) so one hub **`VaultAuth`** backed by **`VaultAuthGlobal`** can serve all spokes. Each consumer namespace must still hold a **`Secret`** named per hub **`vaultHubConfiguration.vaultAuth.appRole.secretRef`** with key **`id`** (AppRole secret ID); replicate with ACM (**[`acm-hub-vault-credential-sync`](../../hub-clusters/day2/applications/acm-hub-vault-credential-sync/README.md)**) or your own process. Same **`vaultAuthRef`** pattern as **[`gitops-repos-config`](../../hub-clusters/day2/applications/gitops-repos-config/README.md)**.

### Key values

| Key | Role |
|-----|------|
| **`cluster`**, **`pullSecretRef`** | Cluster identity and assisted installer pull secret name |
| **`clusterNetworking`** | Rendered under **`ClusterInstance.spec`** (cluster/service/machine networks — validate keys against your ACM/SiteConfig version) |
| **`nodeGroups`** | **`masters`** / **`workers`** lists; expanded to **`nodes[]`** in Tekton via **`expand_node_inventory.py`** |
| **`nodeHostnames`** | Legacy flat list when not using **`nodeGroups`** |
| **`nodes`** | Full **`ClusterInstance`** node entries (legacy static Git, or merged discovery / expand output) |
| **`clusterDefaults`** | Shared **`rootDeviceHints`**, **`nicMapping`** (`logicalName`, **`redfishMemberMatch`** substring on Redfish `@odata.id`) |
| **`bmcAddressTemplate`** | Redfish URL per host; may contain `{hostname}` |
| **`vault`**, **`assistedDeployment.pullSecret`** | KV paths and **`vaultAuthRef`** (`<vso-ns>/<auth-name>`, e.g. **`vault-secrets-operator/vault-auth`**) for **`VaultStaticSecret`** |
| **`nodeReplacement.omitMarkedNodes`** | When **`true`**, entries in **`nodes`** with **`replacementTarget: true`** are omitted from **`ClusterInstance.spec.nodes`** (node replacement suppress phase). Helm strips **`replacementTarget`** / **`replacementPhase`** from emitted YAML. |

## Example (dev hub, after merge)

From the repository root:

```bash
python3 cluster-automation/spoke-automation/ztp-pipeline/files/scripts/merge_pipeline_values.py \
  spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/dev-east-us-1.yaml \
  spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/discovered-nodes.example.yaml \
  /tmp/merged.yaml

python3 cluster-automation/spoke-automation/ztp-pipeline/files/scripts/expand_node_inventory.py /tmp/merged.yaml

helm template dev-east-us-1 ./cluster-automation/ztp-spoke -f /tmp/merged.yaml
```

## GitOps

Usually invoked from **`cluster-automation/spoke-automation/ztp-pipeline`** (OpenShift GitOps Application **`app-tekton-ztp`**). Chart path: **`cluster-automation/ztp-spoke`**.
