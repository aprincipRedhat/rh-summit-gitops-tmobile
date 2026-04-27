# helm/tekton-mirror

Installs an **OpenShift Pipelines** (**OCP Pipelines**) **Pipeline** in **`openshift-pipelines`** that runs **`oc mirror`** using:

- **Workspace `imageset`**: `ConfigMap` volume whose keys are files (default key `ImageSetConfiguration.yaml`).
- **Workspace `registry-auth`**: `Secret` of type `kubernetes.io/dockerconfigjson` in the **same namespace** as the `PipelineRun`.

## Prerequisites

1. Build and push the runner image from [images/oc-mirror](../../images/oc-mirror) and set hub values `tektonMirror.pipeline.mirrorImage`.
2. Create a **pull/push registry secret** (same namespace as the pipeline):

   ```bash
   oc create secret docker-registry mirror-registry-pullsecret \
     --docker-server=registry.example.com:5000 \
     --docker-username=user \
     --docker-password=pass \
     -n openshift-pipelines
   ```

3. Create or enable the example **ConfigMap** (`exampleConfigMap.enabled`) with a valid **ImageSetConfiguration** for your environment.

## Apply

```bash
helm template tekton-mirror . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Run

Use the example `PipelineRun` (if enabled) or create your own, overriding `dest-registry` and workspaces. The parameter `dest-registry` may be `host:port/path` or `docker://host:port/path`.

After **`oc mirror`**, the **`emit-mirror-artifacts`** step prints **ImageDigestMirrorSet** / **ImageTagMirrorSet** YAML (and paths matching `*idms*` / `*itms*`) to the **PipelineRun log** for copy/paste. Nothing is committed to Git from this pipeline for those artifacts.

## RBAC

The chart creates a **Role** limited to `get/list/watch` on the named ConfigMap and Secret. Extend rules if `oc mirror` needs additional API access in your environment.
