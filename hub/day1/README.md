# Hub — Day 1 (ACM bootstrap)

Install **multicluster engine**, **Advanced Cluster Management** operator subscriptions, and **`MultiClusterHub`** before any governance or GitOps day-2 configuration.

## Chart

| Chart | Path |
|-------|------|
| ACM Day 1 | [helm/acm-day1](helm/acm-day1) |

## Apply

From the repository root:

```bash
helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -
```

## Verify

```bash
oc get csv -n multicluster-engine
oc get csv -n open-cluster-management
oc get mch -n open-cluster-management
```

## Next

Hub-wide bootstrap (OpenShift GitOps repo-server patch, OpenShift GitOps bootstrap, then Day 2): [hub/README.md](../README.md). After `MultiClusterHub` is **Running**, continue with [hub/day2/README.md](../day2/README.md).

## References

- [Installing ACM 2.15](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.15/html/install/installing)
