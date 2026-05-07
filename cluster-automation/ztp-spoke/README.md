# Chart: ztp-spoke

## Purpose

Helm chart consumed by the ZTP Tekton pipeline: renders **`ClusterInstance`**, namespace, and related manifests for a spoke cluster.

## Inputs

Values files live under **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/99-pipeline-values/<cluster-name>.yaml`**.

The pipeline resolves exactly one match for **`**/99-pipeline-values/<cluster>.yaml`** before running:

```bash
helm template "<cluster>" ./cluster-automation/ztp-spoke -f "<path-to-values>.yaml"
```

## GitOps

Usually invoked from **`cluster-automation/spoke-automation/ztp-pipeline`** (OpenShift GitOps Application **`app-tekton-ztp`**). Chart path: **`cluster-automation/ztp-spoke`**.

## Example (dev hub)

From the repository root:

```bash
helm template dev-east-us-1 ./cluster-automation/ztp-spoke \
  -f spoke-clusters/dev/east/dev-hub-east-1/99-pipeline-values/dev-east-us-1.yaml
```
