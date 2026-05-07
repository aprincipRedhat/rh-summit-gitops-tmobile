# Spoke clusters (`spoke-clusters/`)

Each hub cluster has its own subtree:

```text
spoke-clusters/<environment>/<site>/<hub-cluster-name>/
  policies/               # Kustomize + PolicyGenerator; paths point at repo-root ../../../../../source-crs/
  99-pipeline-values/<spoke-cluster-name>.yaml
  clusters/<spoke-cluster-name>/manifests.yaml   # written by ZTP pipeline
```

Shared PolicyGenerator manifests live once at repository root: **`source-crs/`** (see **`source-crs/README.md`**).

## GitOps

- **Policies** — OpenShift GitOps `Application` from **`hub-clusters/day2/managed-applications/templates/application-acm-policies.yaml`** (`app-acm-policies-<hub-cluster-name>`), with `spec.source.path` under **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/policies`** (set **`hub.*`** in **`hub-clusters/day2/managed-applications/values.yaml`**).
- **Rendered manifests** — **`ApplicationSet`** in **`hub-clusters/day2/app-of-apps`** uses **`clustersPath: spoke-clusters/*/*/*/clusters`** so each directory under **`clusters/`** becomes a sync target on the hub.

## PolicyGenerator layout

Under each hub’s **`policies/`** directory:

- **`common-gitops-config-pg.yaml`** — example **configuration** policy: **`ArgoCD`** instance resources from **`source-crs/generic-argocd-instance-resources.yaml`** + **patches** (raise limits/requests).
- **`common-operatorpolicy-pg.yaml`** — **`OperatorPolicy`** installs from **`source-crs/generic-operatorpolicy.yaml`** (same file, multiple **patches**).

**`policies/manifests/`** holds **static** **`resources:`** only (namespace **`policies`**, hub-template **RBAC**) — not PolicyGenerator inputs. See **`manifests/README.md`** per hub.

**`path`** entries use **`../../../../../source-crs/...`** (relative to **`policies/kustomization.yaml`**).

OpenShift GitOps repo server sets **`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true`** (via **`policy-generator-gitops-patch`**) so those paths resolve outside the **`policies/`** directory.

## Examples in this repo

- Dev hub: `spoke-clusters/dev/east/dev-hub-east-1/`
- Prod hub: `spoke-clusters/prod/east/prod-hub-east-1/`
