# Cluster automation (`cluster-automation/`)

Shared automation for building and updating spoke clusters.

## Layout

| Path | Role |
|------|------|
| **`spoke-automation/ztp-pipeline`** | Single-cluster ZTP render + Git PR pipeline (Tekton). |
| **`spoke-automation/bulk-ztp-pipeline`** | Bulk fan-out over managed clusters. |
| **`spoke-automation/mirror-pipeline`** | `oc mirror` workflow. |
| **`ztp-spoke`** | Helm chart rendered by ZTP (`ClusterInstance`, namespaces, etc.). |
| **`../custom-container-images/oc-mirror`** (see repo root) | Container image build for the mirror pipeline runner. |

## Data flow

1. Operators commit **`spoke-clusters/<env>/<site>/<hub>/99-pipeline-values/<cluster>.yaml`**.
2. Tekton clones the repo, finds that file, runs **`helm template`** against **`ztp-spoke`**.
3. Output is committed under **`spoke-clusters/<env>/<site>/<hub>/clusters/<cluster>/manifests.yaml`** (by default per hub **`values.yaml`**).
4. OpenShift GitOps **`ApplicationSet`** (from **`hub-clusters/day2/app-of-apps`**) discovers each `clusters/<cluster>/` directory.

## Documentation

- [spoke-automation/ztp-pipeline/README.md](spoke-automation/ztp-pipeline/README.md)
- [ztp-spoke/README.md](ztp-spoke/README.md)
