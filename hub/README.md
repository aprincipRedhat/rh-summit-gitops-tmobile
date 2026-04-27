# Hub

## Purpose

This folder contains the hub cluster lifecycle:

- Day 1: install ACM core components.
- Day 2: install GitOps/bootstrap apps, pipelines, and policy automation.

## Key Steps

1. Day 1 chart (`hub/day1/helm/acm-day1`).
2. PolicyGenerator repo-server patch (`hub/day2/gitops/policy-generator-plugin`).
3. Day 2 GitOps bootstrap chart (`hub/day2/gitops/bootstrap`).
4. Day 2 managed apps sync from `hub/day2/gitops/managed-applications`.

## Quick Commands

```bash
# Day 1
helm template acm-day1 ./hub/day1/helm/acm-day1 -f hub/day1/helm/acm-day1/values.yaml | oc apply -f -

# Day 2 bootstrap
helm template argocd-bootstrap ./hub/day2/gitops/bootstrap -f hub/day2/gitops/bootstrap/values.yaml | oc apply -f -
```

## Next

- `day1/README.md`: ACM Day 1 details.
- `day2/README.md`: Day 2 architecture and commands.
- `hub-values/README.md`: shared values used by Day 2 Helm apps.
