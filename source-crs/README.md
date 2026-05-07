# Shared PolicyGenerator source CRs

Canonical YAML referenced by **PolicyGenerator** manifests under **`spoke-clusters/<env>/<site>/<hub>/policies/`**.

Use one catalog for **every hub**; hub-specific overlays use **`manifests[].patches`** in each hub’s **`*-pg.yaml`** files.

Generic stubs use the **`generic-*.yaml`** naming convention.

## `${VAR}` placeholders

Replace **`replace-me`**-style text with **`${VAR}`** tokens so you can substitute with:

- **`envsubst`** (export `NAME`, `NAMESPACE`, … then `envsubst < generic-namespace.yaml | oc apply -f -`)
- CI/CD string replace
- **PolicyGenerator `patches`** (merge concrete values over the base file)

**Exception:** **`generic-operatorpolicy.yaml`** keeps **`generic-operatorpolicy-placeholder`** / **`placeholder`** subscription fields so **`common-operatorpolicy-pg.yaml`** patches continue to merge correctly (those patches use hub **`{{ fromClusterClaim "name" }}`** where needed).

**`generic-argocd-instance-resources.yaml`** uses **`${SERVER_*}`** / **`${APPLICATIONSET_*}`** for limits and requests. **`common-gitops-config-pg.yaml`** replaces those blocks via **patches** when you enable the policy; for raw apply, run **`envsubst`** with exported variables or patch first.

## Paths from hub `policies/`

From **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/policies/`**:

```text
../../../../../source-crs/<file>.yaml
```

OpenShift GitOps sets **`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true`** (**`policy-generator-gitops-patch`**) so those paths resolve.

## Referenced by this repo’s PolicyGenerator

| File | Tokens / notes |
|------|----------------|
| **`generic-operatorpolicy.yaml`** | Placeholder names for patch merge; ClusterClaim hub template on **`metadata.namespace`**. |
| **`generic-argocd-instance-resources.yaml`** | **`${SERVER_*}`**, **`${APPLICATIONSET_*}`** — overridden by **`common-gitops-config-pg.yaml`** **patches** when enabled. |

## Generic stubs (not wired to any `*-pg.yaml` by default)

| File | Tokens |
|------|--------|
| **`generic-namespace.yaml`** | **`${NAME}`** |
| **`generic-configmap.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${VALUE}`** |
| **`generic-secret.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${USERNAME}`**, **`${PASSWORD}`** |
| **`generic-machineconfig.yaml`** | **`${MC_SUFFIX}`** (`metadata.name` is **`99-worker-${MC_SUFFIX}`**) |
| **`generic-serviceaccount.yaml`** | **`${NAME}`**, **`${NAMESPACE}`** |
| **`generic-role.yaml`** | **`${NAME}`**, **`${NAMESPACE}`** |
| **`generic-rolebinding.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${ROLE_NAME}`**, **`${SERVICE_ACCOUNT_NAME}`** |
| **`generic-clusterrolebinding.yaml`** | **`${NAME}`**, **`${CLUSTER_ROLE_NAME}`**, **`${SERVICE_ACCOUNT_NAME}`**, **`${NAMESPACE}`** |
| **`generic-service.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${APP_LABEL}`** |
| **`generic-persistentvolumeclaim.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${STORAGE_CLASS}`** |
| **`generic-networkpolicy.yaml`** | **`${NAME}`**, **`${NAMESPACE}`**, **`${APP_LABEL}`** |
| **`generic-subscription.yaml`** | **`${NAME}`**, **`${PACKAGE_NAME}`**, **`${CHANNEL}`** |
| **`generic-imagedigestmirrorset.yaml`** | **`${NAME}`**, **`${SOURCE_REGISTRY}`**, **`${MIRROR_REGISTRY}`** |
| **`generic-imagetagmirrorset.yaml`** | **`${NAME}`**, **`${SOURCE_REGISTRY}`**, **`${MIRROR_REGISTRY}`** |

## Submodule or fork

Replace **`source-crs/`** with a **git submodule** if you want a separate catalog repo; keep relative paths or symlink **`source-crs`** at the repo root after clone.
