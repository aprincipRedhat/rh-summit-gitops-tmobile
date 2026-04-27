# Hub Day 1

## Purpose

Day 1 installs ACM core components on the hub cluster:

- multicluster engine
- ACM operator subscription
- `MultiClusterHub`

## Key Path

- Path: `hub/day1/helm/acm-day1`

## Apply

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

Continue with `hub/day2/README.md`.
