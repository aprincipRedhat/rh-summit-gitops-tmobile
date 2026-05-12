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

Use `values.yaml` to set channels and install behavior. Disable VSO with **`vaultSecretsOperator.enabled: false`** if you install it elsewhere.

Confirm the subscription **`channel`** matches your cluster’s marketplace (`oc get packagemanifest vault-secrets-operator -n openshift-marketplace`).

## Render and apply

From the repository root:

```bash
helm template acm-day1 ./hub-clusters/day1/acm-day1 -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f -
```

## Verify

```bash
oc get csv -n multicluster-engine
oc get csv -n open-cluster-management
oc get mch -n open-cluster-management
oc get csv -n vault-secrets-operator
```

## Next

Continue with [../../day2/README.md](../../day2/README.md).
