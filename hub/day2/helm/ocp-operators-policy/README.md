# Chart: ocp-operators-policy

## Purpose

Creates RHACM `OperatorPolicy` resources for hub operator installs:

- OpenShift Pipelines operator
- OpenShift GitOps operator

## Inputs

Uses shared hub values file (`hub/hub-values/.../<hub>.yaml`) with:

- `operators.openshiftPipelines.*`
- `operators.openshiftGitOps.*`

## Apply

```bash
helm template ocp-operators-policy . -f ../../../hub-values/dev/east/hub-values/dev-hub-east-1.yaml | oc apply -f -
```
