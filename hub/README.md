# Hub

This directory is the **ACM hub** lifecycle: **Day 1** installs MCE, ACM, and `MultiClusterHub`; **Day 2** adds OpenShift GitOps bootstrap, **OpenShift Pipelines** (OCP Pipelines) pipelines, mirror assets, and related automation. Spoke content lives under [`../spokes/`](../spokes/) at the repository root.

## Prerequisites

- `oc` and `helm` configured against the **hub** cluster.
- Storage and registry pull secrets per the [ACM install guide](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing) (do not commit secrets).
- After Day 1: **OpenShift GitOps** (`openshift-gitops`) and **OpenShift Pipelines** (`openshift-pipelines`, OCP Pipelines) available on the hub (RHACM policy, OperatorHub, or your standard platform path). Day 2 assumes both are installed.

## Bootstrap the hub (order)

Run these from the **repository root** unless noted.

### 1. Day 1 — ACM hub operators and `MultiClusterHub`

```bash
helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -
```

Wait until `MultiClusterHub` is **Running** and CSVs look healthy. See [hub/day1/README.md](day1/README.md) for verify commands and chart details.

### 2. PolicyGenerator on the OpenShift GitOps repo-server (before OpenShift GitOps syncs `spokes/policies`)

The child Application **`app-acm-policies`** runs `kustomize build` with the ACM PolicyGenerator **alpha** plugin. Patch the OpenShift GitOps **`ArgoCD`** CR so **`openshift-gitops-repo-server`** has the plugin and `kustomizeBuildOptions: --enable-alpha-plugins`.

1. Edit the image reference in [`hub/day2/gitops/policy-generator-plugin/gitops-patch.yaml`](day2/gitops/policy-generator-plugin/gitops-patch.yaml) if needed for your environment.
2. Apply (merge carefully with `oc patch` if you already customize the same `spec` keys):

   ```bash
   oc apply -f hub/day2/gitops/policy-generator-plugin/gitops-patch.yaml
   ```

Wait for **`openshift-gitops-repo-server`** to roll out. Full context: [hub/day2/gitops/policy-generator-plugin/README.md](day2/gitops/policy-generator-plugin/README.md).

### 3. Day 2 — OpenShift GitOps bootstrap (root Application + ApplicationSet)

1. Edit [`hub/day2/gitops/bootstrap/values.yaml`](day2/gitops/bootstrap/values.yaml): set **`repoURL`** and **`targetRevision`** to the Git remote and branch OpenShift GitOps should use (same repo where OCP Pipelines will push `spokes/clusters/<name>/`).
2. Render and apply the bootstrap chart (creates the root **Application** in `openshift-gitops` and the **ApplicationSet** for `spokes/clusters/*`):

   ```bash
   helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```

The root Application syncs [`hub/day2/gitops/managed-applications/`](day2/gitops/managed-applications/), which defines child **Applications** (OCP Pipelines charts, `spokes/policies`, etc.). Ensure the **`repoURL`** / **`targetRevision`** in those manifests match your Git remote (see [hub/day2/gitops/managed-applications/README.md](day2/gitops/managed-applications/README.md)).

More detail: [hub/day2/gitops/bootstrap/README.md](day2/gitops/bootstrap/README.md).

### 4. Day 2 — OCP Pipelines and other charts (if not relying only on OpenShift GitOps)

After OpenShift GitOps is healthy, it can deploy the OCP Pipelines Helm charts from Git via **`managed-applications`**. If you prefer a one-shot install into **`openshift-pipelines`** without waiting for sync, you can still render the charts locally:

```bash
helm template tekton-mirror ./hub/day2/helm/tekton-mirror-pipeline -f hub/day2/helm/tekton-mirror-pipeline/values.yaml | oc apply -f -
helm template tekton-bulk-ztp ./hub/day2/helm/tekton-bulk-ztp-pipeline -f hub/day2/helm/tekton-bulk-ztp-pipeline/values.yaml | oc apply -f -
helm template tekton-ztp ./hub/day2/helm/tekton-ztp-pipeline -f hub/day2/helm/tekton-ztp-pipeline/values.yaml | oc apply -f -
```

Component index, mirror image, and Ansible: [hub/day2/README.md](day2/README.md).

## Documentation map

| Topic | README |
|--------|--------|
| Day 1 ACM install | [hub/day1/README.md](day1/README.md) |
| Day 2 components and apply snippets | [hub/day2/README.md](day2/README.md) |
| GitOps layout (bootstrap, managed apps, PolicyGenerator) | [hub/day2/gitops/README.md](day2/gitops/README.md) |

Repository-wide install order and links: [README.md](../README.md) at the repo root.
