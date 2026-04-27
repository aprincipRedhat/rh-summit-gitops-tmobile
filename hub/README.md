# Hub

This directory is the **ACM hub** lifecycle: **Day 1** installs MCE, ACM, and `MultiClusterHub`; **Day 2** adds OpenShift GitOps bootstrap, **OpenShift Pipelines** (OCP Pipelines) automation, mirror assets, and related workflows.

## Prerequisites

- `oc` and `helm` configured against the **hub** cluster.
- Storage and registry pull secrets per the [ACM install guide](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing) (do not commit secrets).
- After Day 1: **OpenShift GitOps** (`openshift-gitops`) and **OpenShift Pipelines** (`openshift-pipelines`) operators available on the hub.

## Bootstrap the hub (order)

Run these from the repo root unless noted.

### 1) Day 1 - ACM hub operators and `MultiClusterHub`

```bash
helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -
```

Wait until `MultiClusterHub` is **Running**. See [hub/day1/README.md](day1/README.md).

### 2) PolicyGenerator plugin on OpenShift GitOps repo-server

Patch the OpenShift GitOps `ArgoCD` CR so `openshift-gitops-repo-server` can run PolicyGenerator:

```bash
oc apply -f hub/day2/gitops/policy-generator-plugin/example-openshift-gitops-argocd-cr-patch.yaml
```

See [hub/day2/gitops/policy-generator-plugin/README.md](day2/gitops/policy-generator-plugin/README.md).

### 3) Day 2 - OpenShift GitOps bootstrap (root Application + ApplicationSet)

Set `repoURL` and `targetRevision` in [hub/day2/gitops/bootstrap/values.yaml](day2/gitops/bootstrap/values.yaml), then apply:

```bash
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```

### 4) Hub operator policy chart (OpenShift Pipelines + OpenShift GitOps)

Per-hub values live in [hub/hub-values/](hub-values/README.md) using:

`<env>/<site>/hub-values/<hub-cluster>.yaml`

Example:

```bash
helm template ocp-operators-policy ./hub/day2/helm/ocp-operators-policy \
  -f hub/day2/helm/ocp-operators-policy/values.yaml \
  -f hub/hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

In GitOps mode, this chart is synced by `app-ocp-operators-policy` under [hub/day2/gitops/managed-applications/](day2/gitops/managed-applications/).

### 5) OCP Pipelines charts (optional one-shot apply)

If not waiting for OpenShift GitOps sync:

```bash
helm template tekton-mirror ./hub/day2/helm/tekton-mirror-pipeline -f hub/day2/helm/tekton-mirror-pipeline/values.yaml | oc apply -f -
helm template tekton-bulk-ztp ./hub/day2/helm/tekton-bulk-ztp-pipeline -f hub/day2/helm/tekton-bulk-ztp-pipeline/values.yaml | oc apply -f -
helm template tekton-ztp ./hub/day2/helm/tekton-ztp-pipeline -f hub/day2/helm/tekton-ztp-pipeline/values.yaml | oc apply -f -
```

## Documentation map

| Topic | README |
|--------|--------|
| Day 1 ACM install | [hub/day1/README.md](day1/README.md) |
| Day 2 components and apply snippets | [hub/day2/README.md](day2/README.md) |
| GitOps layout (bootstrap, managed apps, PolicyGenerator) | [hub/day2/gitops/README.md](day2/gitops/README.md) |
| Per-hub values | [hub/hub-values/README.md](hub-values/README.md) |
