# oc-mirror runner image

Minimal **UBI 9** image containing **`oc`**, **`kubectl`**, **`oc-mirror`**, and **`skopeo`** (from UBI repos) for **OpenShift Pipelines** (**OCP Pipelines**) mirror pipelines. Registry credentials are **not** baked in; mount a `dockerconfigjson` secret at runtime (see `hub/day2/helm/tekton-mirror`).

## Build

Replace `OCP_CLIENT_VERSION` with a release that publishes both client and `oc-mirror` archives for your architecture (see [mirror.openshift.com clients](https://mirror.openshift.com/pub/openshift-v4/)).

```bash
cd hub/day2/images/oc-mirror
podman build \
  --build-arg OCP_CLIENT_VERSION=4.16.3 \
  --build-arg TARGETARCH=amd64 \
  -t quay.io/myorg/oc-mirror-runner:4.16.3 .
```

For **arm64**:

```bash
podman build --build-arg OCP_CLIENT_VERSION=4.16.3 --build-arg TARGETARCH=aarch64 -t quay.io/myorg/oc-mirror-runner:4.16.3-aarch64 .
```

## Push

```bash
podman push quay.io/myorg/oc-mirror-runner:4.16.3
```

## Smoke test (local)

```bash
podman run --rm quay.io/myorg/oc-mirror-runner:4.16.3 oc version --client
podman run --rm quay.io/myorg/oc-mirror-runner:4.16.3 oc-mirror version
podman run --rm quay.io/myorg/oc-mirror-runner:4.16.3 skopeo --version
```

## Runtime (Kubernetes)

- Mount pull/push **Secret** (`kubernetes.io/dockerconfigjson`) and set `DOCKER_CONFIG` to the directory containing `config.json`, **or** mount at `~/.docker/config.json`.
- Mount **ImageSetConfiguration** YAML (e.g. from a `ConfigMap` volume) and pass `--config /path/to/imageset.yaml`.
- Example `oc mirror` invocation (adjust to your registry):

  ```bash
  oc mirror --config /workspace/imageset/ImageSetConfiguration.yaml docker://registry.example.com:5000/myrepo/mirror
  ```

## Build-time pull auth

Building UBI pulls from `registry.access.redhat.com`. On restricted networks, use `podman build --authfile` or a subscribed builder image per your org.
