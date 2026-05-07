# Chart: ztp-configuration

## Purpose

Creates the **`ztp-common`** namespace on the ACM hub so PolicyGenerator policies, hub templates, and per-cluster ConfigMaps (rendered by **`cluster-automation/.../ztp-spoke`**) have a stable target namespace.

Sync **before** OpenShift GitOps Applications that apply **`spoke-clusters/.../policies`** if those policies assume **`ztp-common`** exists.

## GitOps

Application template: [managed-applications/templates/application-ztp-configuration.yaml](../../managed-applications/templates/application-ztp-configuration.yaml).

## Values

Override **`ztpConfiguration.namespace`** in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`** if your fleet uses a different name (must match **`ztp-spoke`** pipeline values).

## Local render

```bash
helm template ztp-configuration ./hub-clusters/day2/applications/ztp-configuration \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
