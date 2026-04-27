# Hub day2 — OpenShift GitOps app of apps (child Applications)

The **root** `Application` from **`hub/day2/gitops/bootstrap`** syncs this directory. Each manifest here is typically an OpenShift GitOps **`Application`** that points at a **Helm chart** or **Kustomize** directory elsewhere in the same repo.

## Included Applications

| File | Deploys |
|------|---------|
| [application-tekton-mirror.yaml](application-tekton-mirror.yaml) | [hub/day2/helm/tekton-mirror-pipeline](../../helm/tekton-mirror-pipeline) — mirror `Pipeline` + RBAC to **`openshift-pipelines`** |
| [application-tekton-bulk-ztp.yaml](application-tekton-bulk-ztp.yaml) | [hub/day2/helm/tekton-bulk-ztp-pipeline](../../helm/tekton-bulk-ztp-pipeline) — bulk `Pipeline` (ManagedCluster → ZTP `PipelineRun`s, capped concurrency) |
| [application-tekton-ztp.yaml](application-tekton-ztp.yaml) | [hub/day2/helm/tekton-ztp-pipeline](../../helm/tekton-ztp-pipeline) — ZTP render + GitHub PR `Pipeline` |
| [application-acm-policies.yaml](application-acm-policies.yaml) | [spokes/policies](../../../spokes/policies) — Kustomize + **PolicyGenerator** (RHACM policies, **Placement** on **`common: "true"`**). Requires [repo-server plugin](../policy-generator-plugin/README.md). |

## Before you sync

1. Edit **`repoURL`** and **`targetRevision`** in each `Application` to match your Git remote (same values you use in **`hub/day2/gitops/bootstrap/values.yaml`** for the ApplicationSet).

2. Ensure **OpenShift GitOps** is installed and can reconcile `Application` CRs in **`openshift-gitops`**.

3. Create secrets referenced by the charts (e.g. GitHub PAT for the ZTP OCP Pipelines chart, registry pull secret for mirror runs) out of band; OpenShift GitOps only syncs the chart manifests.

4. **PolicyGenerator on OpenShift GitOps:** **`app-acm-policies`** runs `kustomize build` on **`spokes/policies`**, which uses the PolicyGenerator **alpha** plugin. Install the plugin on **`openshift-gitops-repo-server`** and set **`kustomizeBuildOptions: --enable-alpha-plugins`** (see [policy-generator-plugin](../policy-generator-plugin/README.md)).

## Layout note

If you still have an old **`argocd/argocd/managed-applications`** path (duplicate `argocd`), remove it. The canonical app-of-apps path is **`hub/day2/gitops/managed-applications/`**, matching `rootApp.sourcePath` in **`gitops/bootstrap/values.yaml`**.
