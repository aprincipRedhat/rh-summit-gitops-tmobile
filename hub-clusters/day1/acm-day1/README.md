# Chart: acm-day1

## Purpose

Installs ACM Day 1 resources on the hub:

- Multicluster Engine operator subscription
- ACM operator subscription
- `MultiClusterHub`
- **Vault Secrets Operator** (HashiCorp certified; OLM from `certified-operators`) when **`vaultSecretsOperator.enabled`** is true
- **`vaultBootstrap`** — optional placeholder **`Secret`** (`vault-bootstrap-credentials` by default) in the VSO namespace with **`VAULT_ADDR`**, **`VAULT_TOKEN`**, and **`secretId`** keys for Tekton / **`VaultStaticSecret`** workflows (replace **`REPLACE_ME`** before enforcing ACM replication policies)

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
