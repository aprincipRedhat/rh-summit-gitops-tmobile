# acm-spoke-clusters

Hub-side resources required before syncing ACM PolicyGenerator output (`spoke-clusters/.../policies`) via OpenShift GitOps:

- Namespace **`policies`** (destination for generated Policy CRs)
- **`policy-hub-template-lookup`** ServiceAccount in `policies`
- **Role** / **RoleBinding** in **`ztp-common`** allowing that SA to read ConfigMaps (per-cluster operator pins from Helm-rendered manifests)

Configure namespaces via **`acmSpokeClusters`** in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`** (defaults align with **`ztpConfiguration.namespace`**).

Synced by **`app-acm-spoke-clusters`** in **`managed-applications`**.
