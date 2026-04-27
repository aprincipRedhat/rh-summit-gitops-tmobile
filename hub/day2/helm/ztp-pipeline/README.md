# Chart: ztp-pipeline

## Purpose

Creates the single-cluster ZTP Tekton pipeline that:

1. Clones GitOps repo.
2. Runs bundled Ansible (`files/ansible/site.yml` + `files/ansible/roles/`).
3. Renders `ztp-spoke` with `**/pipeline-values/<cluster>.yaml`.
4. Commits and opens a PR with generated manifests.

## Inputs

- Hub values: `tektonZtp.*`
- Bundled Ansible: `files/ansible/`
- GitHub token secret in `openshift-pipelines`

## Repository layout

- Chart directory: `hub/day2/helm/ztp-pipeline/` (from repo root).
- Hub values: `hub/hub-values/<env>/<site>/hub-values/<hub>.yaml`. From this chart, `-f ../../../hub-values/...` resolves to that tree.
- OpenShift GitOps: [managed-applications/application-tekton-ztp.yaml](../../gitops/managed-applications/application-tekton-ztp.yaml) sets `path: hub/day2/helm/ztp-pipeline` and `releaseName: tekton-ztp-pipeline`.

## Apply

```bash
helm template tekton-ztp-pipeline . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

Use the same release name as in the `Application` above if you want a local render to match cluster labels. Use your hub’s values file instead of `dev-hub-east-1.yaml` when not on that hub.

## Related Docs

- `../../../../spokes/pipeline-values/README.md`
- `../../../../spokes/cluster-automation/helm/ztp-spoke/README.md`
