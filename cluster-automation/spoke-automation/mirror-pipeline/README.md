# Chart: mirror-pipeline

Tekton Pipeline: run `oc mirror` using an `ImageSetConfiguration` ConfigMap, then (unless `skip-git-sync=true`) merge IDMS/ITMS into the hub `hub-env-values` file and open a GitHub PR. After merge, ArgoCD re-applies `ztp-disconnected-configuration` so the mirror `ConfigMap` stays current.

Optionally also writes a multi-doc IDMS/ITMS bundle to `spoke-clusters/.../policies/manifests/oc-mirror-idms-itms.yaml` for spoke policy distribution (set `tektonMirror.gitSync.policyManifestRelativePath`).

## Runner image

Build from `custom-container-images/oc-mirror` and set `tektonMirror.pipeline.mirrorImage` in hub values.

## Hub values (`tektonMirror`)

- `pipeline.mirrorImage` — RHEL-based runner with `oc-mirror`, `yq`, `jq`, `gh`, `git`.
- `imageSetConfiguration` — multiline `ImageSetConfiguration` YAML rendered into a ConfigMap.
- `gitSync` — `gitopsRepoUrl`, `hubValuesRelativePath`, `githubRepoSlug`, PR title, policy manifest path.
- `github.secretName` / `github.secretKey` — Secret holding `GH_TOKEN` for git push and PR creation.

## Local render

```bash
helm template tekton-mirror-pipeline ./cluster-automation/spoke-automation/mirror-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
