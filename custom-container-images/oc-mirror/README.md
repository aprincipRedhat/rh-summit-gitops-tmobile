# oc-mirror runner image

Container build context for the **`mirror-pipeline`** Tekton chart (`cluster-automation/spoke-automation/mirror-pipeline`).

## Build

From the repository root:

```bash
cd custom-container-images/oc-mirror
podman build -t registry.ocp.example/oc-mirror-runner:latest .
```

Push to your registry and set **`tektonMirror.pipeline.mirrorImage`** in **`hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`**.
