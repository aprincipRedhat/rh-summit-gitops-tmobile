# Hub Day 2

GitOps bootstrap and Tekton pipeline deployment. Run from the repo root; swap the hub path for your environment.

```bash
# Bootstrap ArgoCD root Application
helm template argocd-bootstrap ./hub-clusters/day2/app-of-apps \
  -f hub-clusters/day2/app-of-apps/values.yaml | oc apply -f -

# Local render examples (ArgoCD manages these after bootstrap)
helm template operator-installations ./hub-clusters/day2/applications/operator-installations \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template tekton-mirror-pipeline ./cluster-automation/spoke-automation/mirror-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -

helm template hub-platform-day2 ./hub-clusters/day2/applications/hub-platform-day2 \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```

Per-hub configuration lives in `hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`. See [hub-env-values/README.md](hub-env-values/README.md) for the key structure and [managed-applications/README.md](managed-applications/README.md) for the full Application index.
