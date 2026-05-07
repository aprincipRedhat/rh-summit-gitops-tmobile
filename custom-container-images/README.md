# Custom container images (`custom-container-images/`)

Repo-maintained **Containerfiles** and build docs for images consumed by Tekton, CI, or operators — **not** vendor platform images.

## Layout

One subdirectory per image (for example **`oc-mirror/`** for the registry mirror runner).

## Consumers

| Directory | Used by |
|-----------|---------|
| `oc-mirror/` | [cluster-automation/spoke-automation/mirror-pipeline](../cluster-automation/spoke-automation/mirror-pipeline/README.md) (`tektonMirror.pipeline.mirrorImage`) |

Add future builds here (e.g. bundled Ansible/ZTP preflight) instead of under `cluster-automation/` or `hub-clusters/`.
