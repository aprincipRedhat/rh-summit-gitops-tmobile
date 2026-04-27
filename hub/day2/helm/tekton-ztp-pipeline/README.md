# Chart: tekton-ztp-pipeline

## Purpose

Creates the single-cluster ZTP Tekton pipeline that:

1. Clones GitOps repo.
2. Runs bundled Ansible preflight.
3. Renders `ztp-spoke` with `**/pipeline-values/<cluster>.yaml`.
4. Commits and opens a PR with generated manifests.

## Inputs

- Hub values: `tektonZtp.*`
- Bundled Ansible content: `files/ansible/`
- GitHub token secret in `openshift-pipelines`

## Apply

```bash
helm template tekton-ztp . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Related Docs

- `../../../../spokes/pipeline-values/README.md`
- `../../../../spokes/cluster-automation/helm/ztp-spoke/README.md`
