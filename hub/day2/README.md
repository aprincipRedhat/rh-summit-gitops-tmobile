# Hub — Day 2 (GitOps, policies, pipelines, mirror)

For the **full hub bootstrap order** (Day 1 → PolicyGenerator patch → OpenShift GitOps bootstrap → Day 2), see **[hub/README.md](../README.md)**.

Apply after **Day 1** is complete and **OpenShift GitOps** and **OpenShift Pipelines** (OCP Pipelines) operators are available (via RHACM policy or manual install).



## Charts and assets



| Component | Path |

|-----------|------|

| RHACM policies (Kustomize + PolicyGenerator) | [spokes/policies](../../spokes/policies) (synced by OpenShift GitOps **`app-acm-policies`**) |

| ZTP per-cluster Helm values (`ztp-spoke`) | [spokes/pipeline-values](../../spokes/pipeline-values) (`**/pipeline-values/<cluster>.yaml`) |

| OpenShift GitOps bootstrap (`ApplicationSet` + root `Application`) | [gitops/bootstrap](gitops/bootstrap) |

| OCP Pipelines mirror pipeline | [helm/tekton-mirror-pipeline](helm/tekton-mirror-pipeline) |

| OCP Pipelines bulk ZTP (ManagedCluster → ZTP `PipelineRun`s) | [helm/tekton-bulk-ztp-pipeline](helm/tekton-bulk-ztp-pipeline) |

| OCP Pipelines ZTP render + GitHub PR | [helm/tekton-ztp-pipeline](helm/tekton-ztp-pipeline) |

| Hub operator policy chart (Pipelines + GitOps operators) | [helm/ocp-operators-policy](helm/ocp-operators-policy) |

| Hub-specific values for hub charts | [../hub-values](../hub-values) (<env>/<site>/hub-values/<hub>.yaml) |

| Ansible preflight (bundled in ZTP chart) | [helm/tekton-ztp-pipeline/files/ansible](helm/tekton-ztp-pipeline/files/ansible) |

| `oc-mirror` image | [images/oc-mirror](images/oc-mirror) |

| OpenShift GitOps app-of-apps Kustomize root (child **Applications** for OCP Pipelines + policies) | [gitops/managed-applications/](gitops/managed-applications/) |

| PolicyGenerator plugin install (for OpenShift GitOps + `spokes/policies`) | [gitops/policy-generator-plugin/](gitops/policy-generator-plugin/) |



Default **ApplicationSet** watches **`spokes/clusters/*`** in Git; the root **Application** syncs **`hub/day2/gitops/managed-applications`**. Edit [gitops/bootstrap/values.yaml](gitops/bootstrap/values.yaml) `repoURL` / `targetRevision` to match your GitOps repo. See [gitops/README.md](gitops/README.md) for the layout.



## Apply (from repo root)



```bash

helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -

helm template ocp-operators-policy ./hub/day2/helm/ocp-operators-policy -f hub/day2/helm/ocp-operators-policy/values.yaml -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -

helm template tekton-mirror ./hub/day2/helm/tekton-mirror-pipeline -f hub/day2/helm/tekton-mirror-pipeline/values.yaml | oc apply -f -

helm template tekton-bulk-ztp ./hub/day2/helm/tekton-bulk-ztp-pipeline -f hub/day2/helm/tekton-bulk-ztp-pipeline/values.yaml | oc apply -f -

helm template tekton-ztp ./hub/day2/helm/tekton-ztp-pipeline -f hub/day2/helm/tekton-ztp-pipeline/values.yaml | oc apply -f -

```



RHACM **Policy** / **Placement** objects are applied when OpenShift GitOps syncs **`spokes/policies`** (child Application **`app-acm-policies`**) or when you run **`kustomize build --enable-alpha-plugins`** there locally / in CI.



## Spoke policies (Kustomize)



Spoke **PolicyGenerator** sources live under **`spokes/policies/`** (from the repository root). Build on a machine with the [policy-generator plugin](https://github.com/open-cluster-management-io/policy-generator-plugin) installed:



```bash

cd spokes/policies

kustomize build --enable-alpha-plugins .

```



Many teams render in CI and apply or commit generated `Policy` YAML to a path OpenShift GitOps syncs.



## Previous step



[hub/day1/README.md](../day1/README.md)


