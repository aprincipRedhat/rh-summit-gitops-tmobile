# Static manifests (`manifests/`)

YAML listed in **`kustomization.yaml`** under **`resources:`** is applied **as-is** by Kustomize and OpenShift GitOps. It is **not** read by PolicyGenerator and is **not** a `path` in any **PolicyGenerator** `manifests` list.

Use **`manifests/`** for:

- Foundation objects the policy stack needs on the **hub** (or sync target) before or alongside generated policies, e.g. the **`policies`** namespace, the **ServiceAccount** and **RBAC** that let **PolicyGenerator** hub templates read **ConfigMaps** in **`ztp-common`**.

Use repository-root **`source-crs/`** for:

- CRs that are **inputs to PolicyGenerator** only — referenced from **`../*-pg.yaml`** with optional **`patches`**.

You can move a manifest into **`source-crs/`** and reference it from a generator if you want the same “base + patch per hub” pattern; keep **`manifests/`** for things you want always present without going through a **Policy** CR.
