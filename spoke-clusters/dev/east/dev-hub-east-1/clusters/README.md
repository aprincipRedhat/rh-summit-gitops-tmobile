# Rendered spoke manifests (dev hub)

The ZTP pipeline chart (**`cluster-automation/spoke-automation/ztp-pipeline`**) writes:

- **`spoke-clusters/dev/east/dev-hub-east-1/clusters/<cluster-name>/manifests.yaml`**

OpenShift GitOps **`ApplicationSet`** from **`hub-clusters/day2/app-of-apps`** watches **`spoke-clusters/*/*/*/clusters/*`** (`clustersPath` in **`values.yaml`**) and syncs each folder to the hub (destination namespace = folder name).

## Related

- Bootstrap chart: [../../../../../hub-clusters/day2/app-of-apps/README.md](../../../../../hub-clusters/day2/app-of-apps/README.md)
- Pipeline chart: [../../../../../cluster-automation/spoke-automation/ztp-pipeline/README.md](../../../../../cluster-automation/spoke-automation/ztp-pipeline/README.md)
