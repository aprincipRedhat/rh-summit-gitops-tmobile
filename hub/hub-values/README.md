# hub/hub-values

Per-hub overrides for hub-scoped Helm applications live under:

`<env>/<site>/hub-values/<hub-cluster>.yaml`

Examples:

- `dev/east/hub-values/dev-hub-east-1.yaml`
- `prod/east/hub-values/prod-hub-east-1.yaml`

Day2 Helm applications now read configuration only from these hub value files. Child
`hub/day2/helm/*/values.yaml` files are intentionally removed.

`hub/day2/helm/ocp-operators-policy` reads:

- `operators.openshiftPipelines.channel`
- `operators.openshiftPipelines.startingCSV`
- `operators.openshiftPipelines.approvedCSVs`
- `operators.openshiftGitOps.channel`
- `operators.openshiftGitOps.startingCSV`
- `operators.openshiftGitOps.approvedCSVs`

`hub/day2/helm/tekton-ztp-pipeline` reads:

- `tektonZtp.serviceAccount.name`
- `tektonZtp.github.secretName`
- `tektonZtp.github.secretKey`
- `tektonZtp.ansible.preflightConfigMapName`
- `tektonZtp.images.*`
- `tektonZtp.pipeline.name`
- `tektonZtp.pipelineRun.example.*`

`hub/day2/helm/tekton-bulk-ztp-pipeline` reads:

- `tektonBulkZtp.serviceAccount.name`
- `tektonBulkZtp.images.cli`
- `tektonBulkZtp.pipeline.name`
- `tektonBulkZtp.target.*`
- `tektonBulkZtp.bulk.*`
- `tektonBulkZtp.childDefaults.*`
- `tektonBulkZtp.pipelineRun.example.*`

`hub/day2/helm/tekton-mirror-pipeline` reads:

- `tektonMirror.pipeline.*`
- `tektonMirror.serviceAccount.name`
- `tektonMirror.rbac.*`
- `tektonMirror.imagesetConfigMapKey`
- `tektonMirror.exampleConfigMap.enabled`
- `tektonMirror.pipelineRun.example.*`

Everything else in Day2 chart templates is statically set.

OpenShift GitOps Applications reference these files through `spec.source.helm.valueFiles`.