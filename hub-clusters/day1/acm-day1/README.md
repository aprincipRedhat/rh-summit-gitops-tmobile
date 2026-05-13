# Chart: acm-day1

Installs on the hub: MCE operator, ACM operator, `MultiClusterHub`, and (when enabled) Vault Secrets Operator + a placeholder `vault-bootstrap-credentials` Secret.

## Operator channels (OCP 4.16–4.20)

| Component | Channel |
|-----------|---------|
| ACM | `release-2.16` |
| MCE | `stable-2.11` |
| Vault Secrets Operator | `stable` |

Verify available channels:
```bash
oc get packagemanifest advanced-cluster-management -n openshift-marketplace \
  -o jsonpath='{.status.channels[*].name}'
```

## Two-phase apply (required on a fresh hub)

`MultiClusterHub` needs the ACM CRD to exist before it can apply.

**Phase 1** — namespaces, OperatorGroups, Subscriptions:
```bash
helm template acm-day1 ./hub-clusters/day1/acm-day1 \
  -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f - 2>&1 || true
```

**Phase 2** — wait for operators, then apply MCH:
```bash
oc wait csv -l operators.coreos.com/multicluster-engine.multicluster-engine="" \
  -n multicluster-engine --for=jsonpath='{.status.phase}'=Succeeded --timeout=600s
oc wait csv -l operators.coreos.com/advanced-cluster-management.open-cluster-management="" \
  -n open-cluster-management --for=jsonpath='{.status.phase}'=Succeeded --timeout=600s
helm template acm-day1 ./hub-clusters/day1/acm-day1 \
  -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f -
```

## Verify
```bash
oc get mch -n open-cluster-management
oc wait mch multiclusterhub -n open-cluster-management \
  --for=jsonpath='{.status.phase}'=Running --timeout=900s
```

## Notes

- Disable VSO with `vaultSecretsOperator.enabled: false` if installed elsewhere.
- Replace `REPLACE_ME` in `vaultBootstrap` with real Vault credentials before enforcing ACM replication policies.
- After OpenShift GitOps is running, enable `acmDay1.enabled: true` in `managed-applications/values.yaml` so Argo adopts these resources — do not double-apply via both `helm template | oc apply` and Argo.
