# helm/tekton-bulk-ztp

OpenShift Pipelines (**OCP Pipelines**) **Pipeline** `bulk-ztp-managed-clusters` in **`openshift-pipelines`** that:

1. Runs **`oc get managedcluster`** (optional **`-l`** label selector).
2. Drops names listed in **`exclude-managed-clusters`** (default `local-cluster`).
3. Creates **PipelineRuns** of the **ZTP** [`tekton-ztp-pipeline`](../tekton-ztp-pipeline) **Pipeline**, one per remaining ManagedCluster, with **`cluster-name`** set to that ManagedCluster name.
4. Processes clusters in **waves**: at most **`max-concurrent`** child PipelineRuns at a time; waits for each wave to finish (**Succeeded** or stops on first **Failed**) before starting the next.

Each child **PipelineRun** only mounts the **`shared`** workspace (PVC). The target ZTP pipeline resolves **`**/pipeline-values/<cluster-name>.yaml`** in the cloned Git repo for that ManagedCluster name, so every name you bulk-process must already have exactly one such file on **`child-git-revision`** (see [`spokes/pipeline-values`](../../../../spokes/pipeline-values/README.md)).

## RBAC

- **ClusterRole** (+ binding): `get/list/watch` **ManagedCluster** (`cluster.open-cluster-management.io`).
- **Role** in `openshift-pipelines`: `create/get/list/watch` **PipelineRun** and `get` **Pipeline**.

The bulk task pod uses in-cluster **`oc`** credentials (pipeline SA); it does not need a kubeconfig Secret if the SA is bound correctly.

## Apply

```bash
helm template tekton-bulk-ztp . -f values.yaml | oc apply -f -
```

## Example PipelineRun

Set `pipelineRun.example.enabled: true` in `values.yaml` only on lab clusters (same caveat as other OCP Pipelines examples).

## Parameters

See `templates/pipeline.yaml` `spec.params` for the full list (target pipeline name/namespace, child Git/GitHub settings, timeouts, etc.).
