# helm/ocp-operators-policy

Installs RHACM **OperatorPolicy** resources on the hub for OpenShift operator subscriptions:

- OpenShift Pipelines (`openshift-pipelines-operator-rh`)
- OpenShift GitOps (`openshift-gitops-operator`)

The chart renders `OperatorPolicy` objects directly in namespace **`local-cluster`**.

## Values

Only these fields are configurable:

- `operators.openshiftPipelines.channel`
- `operators.openshiftPipelines.startingCSV`
- `operators.openshiftPipelines.approvedCSVs`
- `operators.openshiftGitOps.channel`
- `operators.openshiftGitOps.startingCSV`
- `operators.openshiftGitOps.approvedCSVs`

Everything else is statically set in templates.

## Apply

```bash
helm template ocp-operators-policy . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```