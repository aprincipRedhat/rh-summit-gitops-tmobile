# Chart: operator-installations

## Purpose

RHACM **`OperatorPolicy`** resources on the hub. By default this chart installs **OpenShift GitOps** and **OpenShift Pipelines** (Tekton) via subscription pins in **`hub-env-values`** values.

Tekton **pipeline definitions** (ZTP, mirror, etc.) still ship from **`cluster-automation/spoke-automation/`** Applications; this chart only ensures the **Pipelines operator** is present on the hub.

## Inputs

Helm values come from **`hub-clusters/day2/hub-env-values/<env>/<site>/<hub-cluster-name>/values.yaml`**:

- `operators.openshiftGitOps.*` — `channel`, optional `startingCSV`, `approvedCSVs`
- `operators.openshiftPipelines.*` — same shape for **`openshift-pipelines-operator`**

## GitOps

- Chart directory: `hub-clusters/day2/applications/operator-installations/`.
- OpenShift GitOps: [managed-applications/templates/application-operator-installations.yaml](../../managed-applications/templates/application-operator-installations.yaml) — `path: hub-clusters/day2/applications/operator-installations`, `releaseName: operator-installations`.

## Local render

From the repository root:

```bash
helm template operator-installations ./hub-clusters/day2/applications/operator-installations \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
