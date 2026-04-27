# helm/tekton-ztp

OpenShift Pipelines (**OCP Pipelines**) **Pipeline** `ztp-cluster-render-pr` (namespace **`openshift-pipelines`**):

1. **Clone** `gitops-repo-url` at `git-revision` into a workspace.
2. **Ansible** preflight from a **ConfigMap** baked into this chart: playbooks live under [`files/ansible/`](files/ansible/) (`preflight/site.yml`, `requirements.yml`, roles). Helm renders **`ansible.preflightConfigMapName`** (default `ztp-ansible-preflight`) via `.Files.Glob`. The task mounts the ConfigMap, restores a directory tree under `/tmp/ansible-preflight`, then runs `ansible-playbook` with optional `--tags` (default `dns,ping`). Set `skip-ansible=true` to skip.
3. **Resolve** exactly one file `**/pipeline-values/<cluster-name>.yaml` under the cloned repo (`.git` excluded). The **`cluster-name`** parameter must match the YAML **filename** (without `.yaml`).
4. **Helm template** `ztp-chart-relative-path` (default `spokes/cluster-automation/helm/ztp-spoke`) with that values file; write `manifest-output-dir/<cluster-name>/manifests.yaml`.
5. **Git** commit on a new branch and **push** to GitHub (HTTPS + token), then **`gh pr create`**. If `manifest-output-dir/<cluster-name>/manifests.yaml` already exists on the current `HEAD`, the run is treated as a **modify**: branch prefix `update-cluster-…`, commit message `ZTP: update cluster …`, PR title uses `pr-title-prefix-modify`, and the body includes `Change-type: modify` (otherwise `create`).

Example layout: [`spokes/pipeline-values/`](../../../../spokes/pipeline-values/README.md) (e.g. `dev/east/pipeline-values/dev-east-us-1.yaml` for `cluster-name=dev-east-us-1`).

## Prerequisites

- **Secret** `github-tekton-token` (from hub values key `tektonZtp.github.secretName`) in **`openshift-pipelines`**, key `token`, containing a GitHub PAT with `contents:write` and `pull_requests:write` (or fine-grained equivalent).
- GitOps repo clone URL must be **`https://github.com/<org>/<repo>.git`** for the embedded token remote rewrite.
- Repo layout must include **`spokes/cluster-automation/helm/ztp-spoke`** (or override `ztp-chart-relative-path`) and the pipeline-values file for the cluster on the branch being cloned. The GitOps repo does **not** need a separate `hub/day2/ansible` tree.

## Apply

```bash
helm template tekton-ztp . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```

## Example PipelineRun

Set `tektonZtp.pipelineRun.example.enabled: true` in the hub values file only on lab clusters (requires real GitHub token + repo). Ensure the example **`clusterName`** has a matching `**/pipeline-values/<name>.yaml` on **`gitRevision`**.

## RBAC

The chart grants the pipeline **ServiceAccount** permission to **read** the GitHub token secret and the **Ansible preflight ConfigMap** (`ansible.preflightConfigMapName`) in **`openshift-pipelines`**.
