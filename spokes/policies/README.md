# Spoke policies (Policy Generator)

**PolicyGenerator** (`policy-generator.yaml`) produces RHACM **Policy**, **Placement**, and **PlacementBinding** objects in namespace **`policies`**.

## Policies included

| Policy | Placement | Purpose |
|--------|-----------|---------|
| `ztp-demo-apps-namespace-secret` | `common: "true"` | Example **Namespace** + **Secret** |
| `policy-openshift-gitops-pipelines` | `common: "true"` **and** `name: local-cluster` | **OpenShift GitOps** + **OpenShift Pipelines** operator **Subscriptions** (hub self-managed) |
| `policy-ztp-operator-pipelines-pin` | `common: "true"` | Pipelines **Subscription** from hub **ConfigMap** keys (`object-templates-raw` + hub templates); **disabled** by default |

## Prerequisites

1. **ManagedCluster labels:** every cluster that should receive these policies needs **`common: "true"`** on its **ManagedCluster** resource. The hub **`local-cluster`** needs that label too if the GitOps + Pipelines policy should apply. Use **`extraLabels.ManagedCluster`** in the per-cluster file under **[`spokes/pipeline-values`](../pipeline-values/README.md)** (see the example YAMLs there).

2. **Per-cluster hub ConfigMap:** for **`policy-ztp-operator-pipelines-pin`**, ensure OCP Pipelines / **`ztp-spoke`** has created **`ztp-common/<cluster>-unique-config`** with keys such as **`operatorSubscriptionChannel`**, **`operatorInstallPlanApproval`**, **`operatorStartingCSV`** (see **`clusterValues.data`** in pipeline-values examples).

3. **Policy Generator plugin:** `kustomize build --enable-alpha-plugins .`

4. **OpenShift GitOps:** **`openshift-gitops-repo-server`** needs the plugin and `kustomizeBuildOptions: --enable-alpha-plugins` on the **`ArgoCD`** CR (see [hub/day2/gitops/policy-generator-plugin](../../hub/day2/gitops/policy-generator-plugin/README.md)).

## Hub template RBAC

Static manifests under **`manifests/policies-namespace.yaml`** and **`manifests/hub-template-configmap-reader-rbac.yaml`** create namespace **`policies`**, **ServiceAccount** `policy-hub-template-lookup`, and a **Role** + **RoleBinding** in **`ztp-common`** so hub **`fromConfigMap`** resolution can read per-cluster ConfigMaps. The **PolicyGenerator** sets **`policyDefaults.hubTemplateOptions.serviceAccountName`** to that SA.

## Build

```bash
cd spokes/policies
kustomize build --enable-alpha-plugins .
```

## Links

- [Policy generator reference](https://github.com/open-cluster-management-io/policy-generator-plugin/blob/main/docs/policygenerator-reference.yaml)
- [RHACM Governance — Policy Generator](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/governance/governance#integrating-policy-generator)
