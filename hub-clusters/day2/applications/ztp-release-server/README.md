# Chart: ztp-release-server

Hosts CoreOS ISO and rootfs images in-cluster via nginx for disconnected ZTP spoke deployments. Manages `ClusterImageSet` and `AgentServiceConfig` resources driven entirely from hub values.

## Architecture

```
hub-env-values (versions list)
        │
        ├── ClusterImageSet (one per version) → points to mirrored releaseImage
        │
        ├── AgentServiceConfig (spec.osImages) → nginx service URLs
        │
        └── Deployment
              ├── init container (ose-tools-rhel9) — downloads ISO + rootfs to PVC
              └── nginx container — serves /data/<version>/live.iso + rootfs.img
```

## Hub values (`ztpReleaseServer`)

```yaml
ztpReleaseServer:
  enabled: true
  namespace: ztp-release-server
  storage:
    size: 200Gi          # PVC for downloaded artifacts (size all versions * 2)
    storageClass: ""     # blank = cluster default
  agentServiceConfig:
    enabled: true
    databaseStorage:
      size: 10Gi
    filesystemStorage:
      size: 100Gi
  versions:
    - version: "4.20.21"                 # OCP version; used as directory name and ClusterImageSet suffix
      openshiftVersion: "4.20"           # short version for AgentServiceConfig
      rhcosVersion: "420.94.202505220312-0"   # full RHCOS version string
      cpuArchitecture: x86_64
      releaseImage: "image-registry.openshift-image-registry.svc:5000/ocp/release:4.20.21-x86_64"
      coreosIso: "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.20/4.20.21/rhcos-4.20.21-x86_64-live.x86_64.iso"
      rootfsImg: "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.20/4.20.21/rhcos-live-rootfs.x86_64.img"
```

## How it works

1. **PVC** (`ztp-release-data`) stores all downloaded artifacts persistently.
2. **Init container** runs `download.sh` on every pod start. Downloads are idempotent — files already present are skipped.
3. **nginx** serves `/data/` with directory listing. URLs are of the form `http://ztp-release-server.<ns>.svc/<version>/live.iso`.
4. **ClusterImageSet** per version points MCE/Hive at the mirrored `releaseImage`.
5. **AgentServiceConfig** is configured with `spec.osImages` pointing at the nginx service so the Assisted Installer can serve the CoreOS image to booting nodes.

Adding a new OCP version: add an entry to `versions` in hub-env-values. ArgoCD applies the updated ConfigMap, which causes the Deployment to roll (the annotation checksum changes), triggering the init container to download the new files.

## Notes

- `AgentServiceConfig` is a cluster-singleton (`name: agent`). If MCE has already created one, this chart will merge via ServerSideApply. If `databaseStorage`/`filesystemStorage` sizes conflict, delete and recreate.
- `downloaderImage` and `nginxImage` must be available on the hub. In a fully disconnected environment, mirror them via the `oc-mirror` pipeline first.
- For production, use an external registry URL (Quay/Harbor) in `releaseImage` rather than the internal registry.

## Local render

```bash
helm template ztp-release-server ./hub-clusters/day2/applications/ztp-release-server \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml
```
