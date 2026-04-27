# Pipeline values (ZTP / OpenShift Pipelines)

Per-cluster Helm values for [`spokes/cluster-automation/helm/ztp-spoke`](../cluster-automation/helm/ztp-spoke) must live under a path that includes a directory named **`pipeline-values`**, with the file named **`/<cluster-name>.yaml`** (e.g. `dev/east/pipeline-values/dev-east-us-1.yaml`). Only that directory segment and the **filename** matter to OCP Pipelines; `env/site` folders are for your layout.

The ZTP OpenShift Pipelines pipeline takes **`cluster-name`** as a parameter, clones the GitOps repo, and resolves exactly one file:

`**/pipeline-values/<cluster-name>.yaml`

If none or more than one match exists, the pipeline fails.

Examples in this repo:

- [`dev/east/pipeline-values/dev-east-us-1.yaml`](dev/east/pipeline-values/dev-east-us-1.yaml)
- [`prod/east/pipeline-values/prod-east-us-1.yaml`](prod/east/pipeline-values/prod-east-us-1.yaml)
