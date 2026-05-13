# ACM Self-Serve Demo (Summit)

| Area | Purpose |
|------|---------|
| `hub-clusters/` | Hub lifecycle: Day 1 operators, Day 2 app-of-apps, per-hub values (`hub-env-values`). |
| `spoke-clusters/` | Per-hub tree: ACM policies, `99-pipeline-values/<cluster>.yaml`, and rendered manifests under `clusters/<cluster>/`. |
| `cluster-automation/` | Tekton pipeline Helm charts (`spoke-automation/`) and the `ztp-spoke` render chart. |
| `custom-container-images/` | Containerfiles for custom runner images. |
| `source-crs/` | Shared PolicyGenerator source manifests referenced by every hub's `policies/` tree. |

## Install

**Day 1 — ACM, MCE, Vault Secrets Operator:**
```bash
# Phase 1: namespaces, OperatorGroups, Subscriptions
helm template acm-day1 ./hub-clusters/day1/acm-day1 \
  -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f - 2>&1 || true

# Wait for operators, then Phase 2: MultiClusterHub
oc wait csv -l operators.coreos.com/advanced-cluster-management.open-cluster-management="" \
  -n open-cluster-management --for=jsonpath='{.status.phase}'=Succeeded --timeout=600s
helm template acm-day1 ./hub-clusters/day1/acm-day1 \
  -f hub-clusters/day1/acm-day1/values.yaml | oc apply -f -
```

**Day 2 — GitOps bootstrap:**
```bash
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps \
  -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -
```

Once the root Application is running, ArgoCD manages everything else from Git.

## Key paths

| Path | Role |
|------|------|
| `hub-clusters/day1/acm-day1` | MCE, ACM, `MultiClusterHub`, Vault Secrets Operator. |
| `hub-clusters/day2/app-of-apps` | Root ArgoCD `Application` + `ApplicationSet` for spoke manifests. |
| `hub-clusters/day2/managed-applications` | Renders all child ArgoCD `Application` CRs. |
| `hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml` | Per-hub values merged into every Day 2 chart. |
| `cluster-automation/spoke-automation/ztp-pipeline` | Single-cluster ZTP Tekton pipeline. |
| `cluster-automation/ztp-spoke` | Helm chart rendered by the ZTP pipeline (`ClusterInstance`, etc.). |
| `spoke-clusters/<env>/<site>/<hub>/99-pipeline-values/<cluster>.yaml` | Per-spoke inputs for `helm template`. |
| `spoke-clusters/<env>/<site>/<hub>/clusters/<cluster>/manifests.yaml` | Pipeline output; ApplicationSet watches `spoke-clusters/*/*/*/clusters/*`. |
