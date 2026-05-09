# Static manifests (`manifests/`)

Optional directory for YAML referenced from **`kustomization.yaml`** **`resources:`** — applied **as-is** by Kustomize (not PolicyGenerator **`path`** inputs).

The **`policies`** namespace and **`policy-hub-template-lookup`** RBAC for **`ztp-common`** ConfigMaps are deployed from **`hub-clusters/day2/applications/acm-spoke-clusters`** (**`app-acm-spoke-clusters`**) instead of here.

Use **`source-crs/`** at the repo root for PolicyGenerator **`path`** bases.
