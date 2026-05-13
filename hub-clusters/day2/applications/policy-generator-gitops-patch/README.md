# Chart: policy-generator-gitops-patch

## Purpose

Patches the OpenShift GitOps **`ArgoCD`** CR (`openshift-gitops` in namespace **`openshift-gitops`**) so the repo server runs PolicyGenerator as a Kustomize alpha plugin (`--enable-alpha-plugins`), enabling **`spoke-clusters/.../policies`** Kustomize builds that use PolicyGenerator.

The repo server also sets **`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true`** so PolicyGenerator can load manifest **`path`** values outside **`policies/`**, including **`../../../../../source-crs/...`** (repository-root **`source-crs/`** shared by all hub policy trees) in **`spoke-clusters/.../policies/common-operator-*-pg.yaml`**.

## Operational note

Updating the **`ArgoCD`** CR causes the OpenShift GitOps operator to reconcile the GitOps stack. Apply during a suitable maintenance window if your organization requires it.

## GitOps

OpenShift GitOps Application: [managed-applications/templates/application-policy-generator-gitops-patch.yaml](../../managed-applications/templates/application-policy-generator-gitops-patch.yaml).

## Local render

```bash
helm template policy-generator-gitops-patch ./hub-clusters/day2/applications/policy-generator-gitops-patch | oc apply -f -
```

Pin **`policyGeneratorImage`** in `values.yaml` to match your ACM subscription image stream if needed.
