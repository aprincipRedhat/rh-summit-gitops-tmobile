# Shared PolicyGenerator source CRs

Canonical YAML referenced by **PolicyGenerator** manifests under **`spoke-clusters/<env>/<site>/<hub>/policies/`**.

Use one catalog for **every hub** so installs, pins, and shared objects stay consistent; hub-specific behavior belongs in **`policies/common-operator-*-pg.yaml`** via **`manifests[].patches`** or separate PolicyGenerator policies.

## Paths from hub `policies/`

From **`spoke-clusters/<environment>/<site>/<hub-cluster-name>/policies/`**, PolicyGenerator **`path`** values use:

```text
../../../../../source-crs/<file>.yaml
```

(five levels up to the repository root, then into **`source-crs/`**).

OpenShift GitOps runs PolicyGenerator with **`POLICY_GEN_DISABLE_LOAD_RESTRICTORS=true`** (see **`hub-clusters/day2/applications/policy-generator-gitops-patch`**) so these paths resolve outside the **`policies/`** directory.

## Submodule or fork

You can replace **`source-crs/`** with a **git submodule** pointing at a shared catalog repository; keep the same relative paths from each hub’s **`policies/`** folder, or add a symlink at **`source-crs`** after cloning.
