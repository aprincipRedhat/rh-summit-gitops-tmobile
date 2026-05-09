# Chart: ztp-node-replacement

Optional **Tekton Pipeline** skeleton aligned with BO2299 node-replacement narrative: **diagnose** hub-side objects, then **optionally** run guarded **`oc`** steps when **`execute-destructive=true`**.

This repo does **not** automate etcd member removal, OSD teardown, or RAID workflows — integrate those via your runbooks or external Tasks.

## Phases (reference)

1. Update **`99-pipeline-values/<cluster>.yaml`** for replacement hardware / BMC.
2. Run **`get-mac-addresses`** / validation stages from the main ZTP pipeline (or manually refresh MAC data).
3. Regenerate manifests (**`generate-cluster-files`**) and merge via Git PR.
4. For control-plane or storage nodes: remove etcd membership / OSDs **before** deleting **`BareMetalHost`** objects — see OpenShift / ODF documentation.
5. **`execute-destructive`**: patch **`BareMetalHost`** / **`Agent`** suppression flags per your ACM version, delete **`BareMetalHost`**, allow Assisted Installer to reprovision.
6. **`unsuppress`**: restore provisioning once hardware is ready (customer automation).

## Pipeline params

| Param | Purpose |
|-------|---------|
| **`cluster-namespace`** | Namespace of **`ClusterInstance`** / **`BareMetalHost`** resources |
| **`cluster-name`** | **`ClusterInstance`** name |
| **`node-name`** | **`BareMetalHost`** to target |
| **`scenario`** | Informational label (**worker** / **master** / **storage**) |
| **`execute-destructive`** | **`false`** (default): read-only **`oc get`**. **`true`**: runs **`oc delete baremetalhost`** (dangerous). |

## Enable chart

Set **`tektonNodeReplacement.enabled: true`** in **`hub-clusters/day2/99-environments/.../values.yaml`** and sync this chart (no Application wrapper by default — template manually or add one alongside **`application-tekton-ztp.yaml`**).

Use **`pipeline-ztp-gitops`** or a dedicated SA with **`get/list/delete`** on **`BareMetalHost`** / **`ClusterInstance`** in the spoke provisioning namespace.
