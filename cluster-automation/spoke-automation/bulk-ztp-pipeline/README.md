# Chart: bulk-ztp-pipeline

## Purpose

Tekton **Pipeline** that lists ACM `ManagedCluster` objects and starts child **`PipelineRun`** resources against the single-cluster ZTP pipeline (`ztp-cluster-render-pr` by default), with bounded concurrency.

## Dry run and child toggles

- **`dry-run=true`** — prints ManagedClusters that would run and the **`RUN_*`** / **`skip-manual-approval-gate`** values passed to children; creates **no** PipelineRuns.
- **`child-run-sdn-prechecks`**, **`child-run-hardware-validation`**, **`child-run-network-connectivity-test`**, **`child-skip-manual-approval-gate`**, **`child-run-post-deploy-validation`**, **`child-run-kube-burner-tests`** — forwarded to each child **ZTP** PipelineRun (see **`cluster-automation/spoke-automation/ztp-pipeline/README.md`**).

## Hub values

Configured under **`tektonBulkZtp`** in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**. **`childDefaults.manifestOutputDir`** and **`ztpChartRelativePath`** must match the hub’s **`spoke-clusters/.../clusters/`** layout.

## GitOps

- Chart directory: **`cluster-automation/spoke-automation/bulk-ztp-pipeline/`**.
- OpenShift GitOps: [application-tekton-bulk-ztp.yaml](../../../hub-clusters/day2/managed-applications/templates/application-tekton-bulk-ztp.yaml) — `releaseName: tekton-bulk-ztp-pipeline`.

## Local render

```bash
helm template tekton-bulk-ztp-pipeline ./cluster-automation/spoke-automation/bulk-ztp-pipeline \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
