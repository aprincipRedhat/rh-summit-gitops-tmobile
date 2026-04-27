# hub/hub-values

Per-hub overrides for hub-scoped Helm applications live under:

`<env>/<site>/hub-values/<hub-cluster>.yaml`

Examples:

- `dev/east/hub-values/dev-hub-east-1.yaml`
- `prod/east/hub-values/prod-hub-east-1.yaml`

The `hub/day2/helm/ocp-operators-policy` chart reads only these keys:

- `operators.openshiftPipelines.channel`
- `operators.openshiftPipelines.startingCSV`
- `operators.openshiftPipelines.approvedCSVs`
- `operators.openshiftGitOps.channel`
- `operators.openshiftGitOps.startingCSV`
- `operators.openshiftGitOps.approvedCSVs`

Everything else in the operator policies is statically set in chart templates.

OpenShift GitOps Applications reference these files through `spec.source.helm.valueFiles`.