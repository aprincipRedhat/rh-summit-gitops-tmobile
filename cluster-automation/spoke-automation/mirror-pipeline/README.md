# Chart: mirror-pipeline

## Purpose

Tekton **Pipeline** that runs **`oc mirror`** using an `ImageSetConfiguration` ConfigMap and registry credentials Secret, writes manifests under **`workspace/mirror-artifacts`**, then (unless **`skip-git-sync=true`**) parses **`ImageDigestMirrorSet`** / **`ImageTagMirrorSet`** YAML, merges **`ztpDisconnected.imageDigestMirrorSets`** / **`imageTagMirrorSets`** into the hub **`99-environments`** values file you configure (**`tektonMirror.gitSync.hubValuesRelativePath`**), commits, pushes, and opens a GitHub PR. After merge, Argo reapplies **`ztp-disconnected-configuration`** so the mirror **`ConfigMap`** (Assisted Installer / disconnected ZTP) matches **`oc mirror`** output — the hub chart does not apply IDMS/ITMS cluster CRs on the hub API.

When **`tektonMirror.gitSync.policyManifestRelativePath`** is set and **`skip-policy-manifest-sync`** is not **true**, the promote step also writes a multi-doc YAML bundle (same IDMS/ITMS documents found under **`mirror-artifacts`**) to **`spoke-clusters/<hub>/policies/manifests/oc-mirror-idms-itms.yaml`** so ACM Policy / GitOps can apply mirror routing on **spokes**. Keep **`ztpDisconnected`** (hub ConfigMap) and **`policies/manifests`** (spoke-bound bundle) reconciliations aligned via the **same PR**.

## Runner image

Build from **[../../../custom-container-images/oc-mirror](../../../custom-container-images/oc-mirror)** (relative to this chart: **`../../../custom-container-images/oc-mirror`**).

## Hub values

Pins live under **`tektonMirror`** in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**.

- **`github.secretName` / `github.secretKey`** — Secret in **`openshift-pipelines`** holding **`GH_TOKEN`** for **`git push`** and **`gh pr create`** (referenced only when the promote task runs; use **`skip-git-sync=true`** to mirror only without Git).
- **`gitSync`** — defaults for **`gitops-repo-url`**, **`hub-values-relative-path`**, **`github-repo-slug`**, branch names, **`yq`** / **`gh`** versions, etc.
- **`images.alpineTools`** — image for the promote step (Alpine-based; installs **`yq`** / **`gh`** at runtime).

## GitOps

- Chart directory: **`cluster-automation/spoke-automation/mirror-pipeline/`**.
- OpenShift GitOps: [application-tekton-mirror.yaml](../../../hub-clusters/day2/managed-applications/templates/application-tekton-mirror.yaml) — `releaseName: tekton-mirror-pipeline`.

## Local render

```bash
helm template tekton-mirror-pipeline ./cluster-automation/spoke-automation/mirror-pipeline \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
