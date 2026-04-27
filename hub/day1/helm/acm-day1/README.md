# helm/acm-day1

Installs **multicluster engine**, **Advanced Cluster Management** operator subscriptions, and **`MultiClusterHub`** on the hub cluster.

## Before you apply

1. Complete OCP prerequisites from the [ACM 2.15 install guide](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing) (storage class, worker capacity, pull secret for Red Hat registries).
2. **Apply multicluster engine first** — this chart applies MCE and ACM resources in one shot; the ACM subscription may not succeed until MCE CSV is ready. If installs race, apply templates in two phases (comment out ACM `Subscription` and `MultiClusterHub`, apply MCE only, wait for CSV, then apply the rest).

## Render and apply

```bash
helm template acm-day1 . -f values.yaml | oc apply -f -
```

## Verify

```bash
oc get csv -n multicluster-engine
oc get csv -n open-cluster-management
oc get mch -n open-cluster-management
```

Tune `values.yaml`: `channel`, `installPlanApproval`, optional `startingCSV`, and `multiClusterHub.spec` (HA, ingress, storage overrides per documentation).
