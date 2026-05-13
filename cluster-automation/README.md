# Cluster automation (`cluster-automation/`)

| Path | Role |
|------|------|
| `spoke-automation/ztp-pipeline` | Single-cluster ZTP render + Git PR pipeline. |
| `spoke-automation/bulk-ztp-pipeline` | Fan-out over ACM `ManagedClusters` with bounded concurrency. |
| `spoke-automation/mirror-pipeline` | `oc mirror` + Git promotion of mirror metadata. |
| `spoke-automation/mirror-tenant-triggers` | Tekton Triggers — HTTP POST starts the mirror pipeline with a tenant-supplied `ImageSetConfiguration` ConfigMap. |
| `spoke-automation/ztp-node-replacement` | Legacy standalone node-replacement pipeline (prefer the integrated flow in `ztp-pipeline`). |
| `ztp-spoke` | Helm chart rendered by the ZTP pipeline (`ClusterInstance`, namespaces, etc.). |

## Pipeline task flow

### ztp-pipeline

```mermaid
flowchart TD
  A[clone-repos] --> D[detect-node-replacement]
  D -->|none| B[preflight-sdn]
  B --> C[discover-node-network]
  C --> E[preflight-network]
  E --> F[manual-approval-gate]
  F --> G[generate-cluster-files]
  G --> H[git-commit-and-mr]
  H --> I[wait-for-merge]
  I --> J[deploy-cluster]
  J --> K[post-deploy-validation]
  D -->|full| R[replacement_tasks]
```

### bulk-ztp-pipeline

```mermaid
flowchart TD
  SP[spawn-ztp-pipelineruns] --> W[wave_create_wait_child_ZTP_PipelineRuns]
```

### mirror-pipeline

```mermaid
flowchart LR
  A[oc-mirror] --> B[promote-to-git]
```

### mirror-tenant-triggers

```mermaid
flowchart LR
  HTTP[HTTP_POST_EventListener] --> TB[TriggerBinding] --> TT[TriggerTemplate] --> PR[PipelineRun]
```

## Data flow

1. Operator commits `spoke-clusters/<env>/<site>/<hub>/99-pipeline-values/<cluster>.yaml`.
2. Tekton clones the repo, runs Ansible preflight (DNS, Redfish MAC discovery), then `helm template` against `ztp-spoke`.
3. Output is committed to `spoke-clusters/<env>/<site>/<hub>/clusters/<cluster>/manifests.yaml`.
4. ArgoCD `ApplicationSet` (from `hub-clusters/day2/app-of-apps`) syncs each `clusters/<cluster>/` directory to the hub.
