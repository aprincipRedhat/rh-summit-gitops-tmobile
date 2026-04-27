# Chart: acm-day1

## Purpose

Installs ACM Day 1 resources on the hub:

- multicluster engine operator subscription
- ACM operator subscription
- `MultiClusterHub`

## Inputs

Use `values.yaml` to set channels and install behavior.

## Render and Apply

```bash
helm template acm-day1 . -f values.yaml | oc apply -f -
```

## Verify

```bash
oc get csv -n multicluster-engine
oc get csv -n open-cluster-management
oc get mch -n open-cluster-management
```
