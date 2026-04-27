# PolicyGenerator Plugin (OpenShift GitOps)

## Purpose

Use this when `spokes/policies` is synced by OpenShift GitOps and requires PolicyGenerator.

## Key Outputs

- `kustomize build --enable-alpha-plugins` in repo-server
- PolicyGenerator binary available in repo-server plugin path

## Files

- `gitops-patch.yaml`: example `ArgoCD` CR patch for repo-server plugin setup.
- `example-openshift-gitops-argocd-cr-patch.yaml`: example patch manifest.

## Apply

```bash
oc apply -f gitops-patch.yaml
```

Then restart/verify `openshift-gitops-repo-server` rollout.
