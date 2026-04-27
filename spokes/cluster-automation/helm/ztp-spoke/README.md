# spokes/cluster-automation/helm/ztp-spoke

Helm chart that renders **hub-side** resources for SiteConfig-driven ZTP: spoke **Namespace**, **`ClusterInstance`**, and optional **`ztp-common`** resources (hub namespace + per-cluster **ConfigMap** of arbitrary string settings from `clusterValues.data`).

## Important

- **`ClusterInstance`** field names and nested structures must match the [ClusterInstance API](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html-single/apis#clusterinstance-api) and your **installation templates** on the hub. This chart is a **starting point**; adjust `templates/clusterinstance.yaml` when the API differs.
- **Secrets** (`pull-secret`, BMC credentials) must be created **out of band** on the hub; this chart only references **names**.
- **`templateRefs`** must point at real `InstallationTemplate` / template objects created per the [SiteConfig documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/multicluster_engine_operator_with_red_hat_advanced_cluster_management/siteconfig-intro).

## Values file (pipeline-values)

There is **no** `values.yaml` in this chart. Per-cluster inputs live in the Git repo under **`**/pipeline-values/<cluster-name>.yaml`** (see [`spokes/pipeline-values`](../../../pipeline-values/README.md)). OCP Pipelines and local renders pass that file with **`-f`**.

## Render (local)

```bash
helm template dev-east-us-1 . \
  -f ../../../pipeline-values/dev/east/pipeline-values/dev-east-us-1.yaml \
  > /tmp/manifests.yaml
```

Use the same pattern from the ZTP OpenShift Pipelines pipeline (default chart path **`spokes/cluster-automation/helm/ztp-spoke`**).

## ManagedCluster labels (`extraLabels`)

Use **`extraLabels.ManagedCluster`** in your pipeline-values file so labels land on the **ManagedCluster** object (see [upstream sample](https://raw.githubusercontent.com/stolostron/siteconfig/main/config/samples/siteconfig_v1alpha1_clusterinstance.yaml)). Example policies under **[`spokes/policies`](../../../policies)** select clusters with **`common: "true"`**; set that key in pipeline-values.

## `ztp-common` and `clusterValues.data`

When `ztpCommon.enabled` is true (default), the chart creates namespace `ztpCommon.namespace` (default `ztp-common`) and a ConfigMap named **`<cluster.name>-unique-config`** in that namespace.

**`data:`** contents:

- **`clusterName`** — always set from `Values.cluster.name` (do not duplicate this key inside `clusterValues.data`).
- **All keys under `clusterValues.data`** — arbitrary **string** values rendered as literal blocks (trimmed). Examples: **`etcdBackupSchedule`**, **`operatorSubscriptionChannel`**, **`operatorStartingCSV`**, **`operatorInstallPlanApproval`** for policies that read the ConfigMap via hub templates.

See **[`spokes/pipeline-values`](../../../pipeline-values)** and **[`spokes/policies`](../../../policies)** (`policy-ztp-operator-pipelines-pin`).
