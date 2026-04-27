# Policy Generator plugin for OpenShift GitOps

**OpenShift GitOps** **`openshift-gitops-repo-server`** runs `kustomize build` **without** the ACM **PolicyGenerator** plugin by default. Your [`spokes/policies`](../../../spokes/policies) tree uses `generators:` in `kustomization.yaml`, so you must either:

1. **Install the plugin into the OpenShift GitOps `ArgoCD` CR’s repo-server** (this folder), or  
2. **Pre-render** in CI (`kustomize build --enable-alpha-plugins`) and sync plain YAML from a different path (no plugin in-cluster).

This folder documents **option 1** using the **Red Hat** `multicluster-operators-subscription` image, which already ships the policy-generator binaries.

## What to configure

| Requirement | Why |
|-------------|-----|
| `kustomizeBuildOptions: --enable-alpha-plugins` | PolicyGenerator is a Kustomize **alpha** generator. |
| `KUSTOMIZE_PLUGIN_HOME=/etc/kustomize/plugin` | Kustomize resolves plugins under this tree (must match `repo.volumeMounts` prefix). |
| `repo.initContainers` | Copies **`PolicyGenerator-not-fips-compliant`** from the subscription image into the shared `emptyDir` as **`PolicyGenerator`** at the path Kustomize expects. |
| `repo.volumes` / `volumeMounts` | Mount the plugin directory at **`…/policy.open-cluster-management.io/v1/policygenerator`** on the **repo-server** pod. |

## Apply (OpenShift GitOps)

1. Edit the image tag in **[gitops-patch.yaml](gitops-patch.yaml)** to a **`registry.redhat.io/rhacm2/multicluster-operators-subscription-rhel9`** digest or tag that matches your environment (and that contains `/policy-generator/PolicyGenerator-not-fips-compliant`).
2. Merge the `spec` fragment into your live OpenShift GitOps **`ArgoCD`** CR:

   ```bash
   oc apply -f gitops-patch.yaml
   ```

   Prefer **`oc patch`** / GitOps-managed merge if you must not replace unrelated `spec` keys.

3. Wait for **`openshift-gitops-repo-server`** to roll out.

4. Ensure **`application-acm-policies.yaml`** is listed in **[managed-applications/kustomization.yaml](../managed-applications/kustomization.yaml)** `resources:` so OpenShift GitOps syncs **`spokes/policies`** (after the repo-server patch is applied).

## References

- [policy-generator-plugin](https://github.com/open-cluster-management-io/policy-generator-plugin) (community binary layout; RH image path differs as in the example YAML)
- [OpenShift GitOps — Argo CD instance / `ArgoCD` CR](https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/1.12/html-single/argo_cd_instance/index) (`kustomizeBuildOptions`, `repo.initContainers`, `repo.volumes`)
