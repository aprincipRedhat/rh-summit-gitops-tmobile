# Chart: acm-day1

## Purpose

Installs ACM Day 1 resources on the hub:

- Multicluster Engine operator subscription
- ACM operator subscription
- `MultiClusterHub`
- **Vault Secrets Operator** (HashiCorp certified; OLM from `certified-operators`) when **`vaultSecretsOperator.enabled`** is true
- **`vaultBootstrap`** — optional placeholder **`Secret`** (`vault-bootstrap-credentials` by default) in the VSO namespace with **`VAULT_ADDR`**, **`VAULT_TOKEN`**, and **`secretId`** keys for Tekton / **`VaultStaticSecret`** workflows (replace **`REPLACE_ME`** before enforcing ACM replication policies)

## GitOps (recommended after OpenShift GitOps is running)

To manage the same resources from Git and your per-hub **`hub-env-values`** file (reduce drift):

1. Ensure **`openshift-gitops`** is installed (e.g. OperatorPolicy from **`operator-installations`** or day-0) and the root **`Application`** (**`root-day2-applications`**) syncs **`managed-applications`**.
2. In **`hub-clusters/day2/managed-applications/values.yaml`**, set **`acmDay1.enabled: true`** for that repo clone (with **`hub.*`** identity aligned to this hub).
3. Put **`mce`**, **`acm`**, **`multiClusterHub`**, **`vaultSecretsOperator`**, and **`vaultBootstrap`** overrides in **`hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`** (see dev/prod examples in this repo). Argo **`app-acm-day1`** points Helm at this chart and merges that file.

Avoid applying the same subscriptions twice: either use **manual `helm template | oc apply` once** then **enable Argo** so it adopts the live objects, or **only** use Argo after a fresh hub where ACM was never applied manually.

## Inputs

Confirm channels before applying. For OCP 4.16–4.20, use:

| Component | Channel | Command to verify |
|-----------|---------|-------------------|
| ACM | `release-2.16` | `oc get packagemanifest advanced-cluster-management -n openshift-marketplace -o jsonpath='{.status.channels[*].name}'` |
| MCE | `stable-2.11` | `oc get packagemanifest multicluster-engine -n openshift-marketplace -o jsonpath='{.status.channels[*].name}'` |
| Vault Secrets Operator | `stable` | `oc get packagemanifest vault-secrets-operator -n openshift-marketplace -o jsonpath='{.status.defaultChannel}'` |

Disable VSO with **`vaultSecretsOperator.enabled: false`** if you install it elsewhere.

## Render and apply — two-phase (required on a fresh hub)

The `MultiClusterHub` CR requires the ACM operator CRD to exist before it can be applied. Apply in two steps from the repository root:

**Phase 1 — namespaces, OperatorGroups, Subscriptions, VSO Secret:**

```bash
helm template acm-day1 ./hub-clusters/day1/acm-day1 -f hub-clusters/day1/acm-day1/values.yaml \
  | oc apply -f - 2>&1 || true
```

The `MultiClusterHub` will fail with `no matches for kind "MultiClusterHub"` on a fresh cluster — that is expected. All other resources (namespaces, OperatorGroups, Subscriptions, Secret) apply successfully.

**Phase 2 — wait for ACM operator, then apply MCH:**

```bash
# Wait for MCE CSV (may take 3-5 minutes)
oc wait csv \
  -l operators.coreos.com/multicluster-engine.multicluster-engine="" \
  -n multicluster-engine \
  --for=jsonpath='{.status.phase}'=Succeeded --timeout=600s

# Wait for ACM CSV
oc wait csv \
  -l operators.coreos.com/advanced-cluster-management.open-cluster-management="" \
  -n open-cluster-management \
  --for=jsonpath='{.status.phase}'=Succeeded --timeout=600s

# Re-apply — MultiClusterHub will succeed this time
helm template acm-day1 ./hub-clusters/day1/acm-day1 -f hub-clusters/day1/acm-day1/values.yaml \
  | oc apply -f -
```

## Verify

```bash
oc get csv -n multicluster-engine
oc get csv -n open-cluster-management
oc get mch -n open-cluster-management
oc get csv -n vault-secrets-operator
```

Wait for `MultiClusterHub` to reach `Running` phase (can take 5–15 minutes):

```bash
oc wait mch multiclusterhub -n open-cluster-management \
  --for=jsonpath='{.status.phase}'=Running --timeout=900s
```

## Next

Continue with [../../day2/README.md](../../day2/README.md).
