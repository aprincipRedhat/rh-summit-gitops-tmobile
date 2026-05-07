# Shared PolicyGenerator source CRs

Canonical YAML referenced by **PolicyGenerator** manifests under **`spoke-clusters/<env>/<site>/<hub>/policies/`**.

Use one catalog for **every hub**; hub-specific overlays use **`manifests[].patches`** in each hub’s **`*-pg.yaml`** files.

Generic stubs use the **`generic-*.yaml`** naming convention.

## Paths from hub `policies/`

From **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/policies/`**:

```text
../../../../../source-crs/<file>.yaml
```

OpenShift GitOps sets **`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true`** (**`policy-generator-gitops-patch`**) so those paths resolve.

## Referenced by this repo’s PolicyGenerator

| File | Purpose |
|------|---------|
| **`generic-operatorpolicy.yaml`** | **`OperatorPolicy`** skeleton (ClusterClaim **`name`** namespace); reuse with **patches** per operator. |
| **`generic-argocd-instance-resources.yaml`** | **`ArgoCD`** instance resources; tune via **`common-gitops-config-pg.yaml`** **patches**. |

## Generic stubs (not wired to any `*-pg.yaml` by default)

| File | Kind |
|------|------|
| **`generic-namespace.yaml`** | Namespace |
| **`generic-configmap.yaml`** | ConfigMap |
| **`generic-secret.yaml`** | Secret (Opaque) |
| **`generic-machineconfig.yaml`** | MachineConfig (worker) |
| **`generic-deployment.yaml`** | Deployment |
| **`generic-daemonset.yaml`** | DaemonSet |
| **`generic-statefulset.yaml`** | StatefulSet |
| **`generic-serviceaccount.yaml`** | ServiceAccount |
| **`generic-role.yaml`** | Role |
| **`generic-rolebinding.yaml`** | RoleBinding |
| **`generic-clusterrole.yaml`** | ClusterRole |
| **`generic-clusterrolebinding.yaml`** | ClusterRoleBinding |
| **`generic-service.yaml`** | Service |
| **`generic-route.yaml`** | Route (OpenShift) |
| **`generic-ingress.yaml`** | Ingress |
| **`generic-persistentvolumeclaim.yaml`** | PersistentVolumeClaim |
| **`generic-networkpolicy.yaml`** | NetworkPolicy |
| **`generic-operatorgroup.yaml`** | OperatorGroup |
| **`generic-subscription.yaml`** | Subscription (OLM) |
| **`generic-imagedigestmirrorset.yaml`** | ImageDigestMirrorSet |
| **`generic-imagetagmirrorset.yaml`** | ImageTagMirrorSet |

## Submodule or fork

Replace **`source-crs/`** with a **git submodule** if you want a separate catalog repo; keep relative paths or symlink **`source-crs`** at the repo root after clone.
