# Hub Day 2 (`hub-clusters/day2/`)

Day 2 automation on the hub: OpenShift GitOps bootstrap, managed Applications, shared environment values, and optional PolicyGenerator plugin support.

## Commands (smoke)

Paths below are from the repository root.

```bash
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -

helm template managed-apps ./hub-clusters/day2/managed-applications -f hub-clusters/day2/managed-applications/values.yaml

helm template operator-installations ./hub-clusters/day2/applications/operator-installations \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template policy-generator-gitops-patch ./hub-clusters/day2/applications/policy-generator-gitops-patch | oc apply -f -

helm template ztp-configuration ./hub-clusters/day2/applications/ztp-configuration \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template tekton-bulk-ztp-pipeline ./cluster-automation/spoke-automation/bulk-ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template tekton-mirror-pipeline ./cluster-automation/spoke-automation/mirror-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template hub-platform-day2 ./hub-clusters/day2/applications/hub-platform-day2 \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```

Swap `dev-hub-east-1` / environment folders for the hub you are configuring.

## Related docs

- **`app-acm-day1`** — Optional Argo-managed ACM Day1: set **`acmDay1.enabled`** in **`managed-applications/values.yaml`** (see [managed-applications/README.md](managed-applications/README.md) and [../day1/acm-day1/README.md](../day1/acm-day1/README.md)).
- [applications/README.md](applications/README.md)
- [app-of-apps/README.md](app-of-apps/README.md)
- [hub-env-values/README.md](hub-env-values/README.md)
- Spoke inputs and rendered manifests: [../../spoke-clusters/README.md](../../spoke-clusters/README.md)
- Pipelines and render chart: [../../cluster-automation/README.md](../../cluster-automation/README.md)
