# oc-mirror Runner Image

## Purpose

Container image used by the Day 2 mirror pipeline.

Includes:

- `oc`
- `oc-mirror`
- `kubectl`
- `skopeo`

## Build

```bash
cd hub/day2/images/oc-mirror
podman build --build-arg OCP_CLIENT_VERSION=4.16.3 --build-arg TARGETARCH=amd64 -t quay.io/myorg/oc-mirror-runner:4.16.3 .
```

## Push

```bash
podman push quay.io/myorg/oc-mirror-runner:4.16.3
```

Set the image in hub values under `tektonMirror.pipeline.mirrorImage`.
