# ACM self-serve demo (Summit)



Repository split into **hub** (day1 / day2 lifecycle) and **spokes** (cluster manifests + ZTP policies).



## Packaging



| Area | Tooling |

|------|---------|

| **Hub** `hub/day1/` and `hub/day2/` | **Helm** charts (`helm template` / `helm upgrade --install`) |

| **Spokes** `spokes/cluster-automation/helm/ztp-spoke` | **Helm** (rendered `ClusterInstance` + namespace); values in **`spokes/pipeline-values`** |

| **Spokes** `spokes/policies/` | **Kustomize** + **PolicyGenerator** plugin (`kustomize build --enable-alpha-plugins`) |



## Documentation (ACM 2.15)



- [Installing Red Hat Advanced Cluster Management](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing)

- [SiteConfig / ClusterInstance](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/multicluster_engine_operator_with_red_hat_advanced_cluster_management/siteconfig-intro)

- [GitOps with ACM](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html-single/gitops/index)

- [ClusterInstance API](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html-single/apis#clusterinstance-api)

- [Policy Generator (Governance)](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/governance/governance#integrating-policy-generator)



## Repository layout



| Path | Description |

|------|-------------|

| [hub/](hub/) | **Hub bootstrap order** (Day 1 → GitOps patch → OpenShift GitOps bootstrap → Day 2); links to day1/day2 |

| [hub/day1/](hub/day1/) | ACM hub bootstrap (MCE, ACM operator, `MultiClusterHub`) |

| [hub/day2/](hub/day2/) | Day-2 hub: OCP Pipelines, OpenShift GitOps bootstrap, hub operator policy chart, Ansible, mirror image; RHACM policies sync from **`spokes/policies`** via OpenShift GitOps |

| [spokes/cluster-automation/](spokes/cluster-automation/) | **`ztp-spoke`** Helm chart (used by OCP Pipelines) + pointer to policies |

| [spokes/policies](spokes/policies) | Kustomize + `PolicyGenerator` policy sources |

| [spokes/pipeline-values/](spokes/pipeline-values/) | Per-cluster Helm values for **`ztp-spoke`** (`**/pipeline-values/<cluster>.yaml`) |

| [hub/hub-values/](hub/hub-values/) | Per-hub values for hub charts (<env>/<site>/hub-values/<hub>.yaml) |

| [spokes/clusters/](spokes/clusters/) | **Git output** from ZTP OpenShift Pipelines pipeline (one dir per cluster); created by automation, not shipped empty |



See **[hub/README.md](hub/README.md)** for hub bootstrap steps, then [hub/day1/README.md](hub/day1/README.md) and [hub/day2/README.md](hub/day2/README.md) for chart-level detail.



## Install order (summary)



1. **Prerequisites:** StorageClass, pull secret for Red Hat registries (see ACM install guide). Do not commit secrets.



2. **Day 1 — ACM hub** (full sequence: [hub/README.md](hub/README.md))



   ```bash

   helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -

   ```



3. **Day 2 — OpenShift GitOps, OCP Pipelines** (commands in [hub/day2/README.md](hub/day2/README.md) and [hub/README.md](hub/README.md)); **`app-acm-policies`** syncs **`spokes/policies`** (requires PolicyGenerator on the OpenShift GitOps repo-server — see [hub/day2/gitops/policy-generator-plugin/README.md](hub/day2/gitops/policy-generator-plugin/README.md)).



4. **Build mirror image** — [hub/day2/images/oc-mirror/README.md](hub/day2/images/oc-mirror/README.md)



5. **Spoke policies** (optional, on workstation or CI):



   ```bash

   cd spokes/policies

   kustomize build --enable-alpha-plugins . | oc apply -f -

   ```



6. **ZTP flow:** run the ZTP OpenShift Pipelines pipeline; PR adds `spokes/clusters/<name>/`; merge; OpenShift GitOps **ApplicationSet** syncs that path to the hub.



**GitOps for pipelines/operators:** After you apply **`hub/day2/gitops/bootstrap`**, the **root** `Application` syncs **`hub/day2/gitops/managed-applications/`**, which contains child **`Application`** manifests for **`app-ocp-operators-policy`**, **`app-tekton-mirror`**, **`app-tekton-bulk-ztp`**, **`app-tekton-ztp`**, and **`app-acm-policies`** (edit `repoURL` in those files to match your Git remote). Per-hub operator settings come from `hub/hub-values/.../<hub>.yaml` via Helm `valueFiles`.


