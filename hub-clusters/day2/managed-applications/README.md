# Managed Applications (OpenShift GitOps)

Helm chart **`managed-applications`** renders child **`Application`** resources consumed by the root Application **`root-day2-applications`** (`hub-clusters/day2/app-of-apps` → `rootApp.sourcePath`).

## Hub identity and `99-environments`

Edit **`values.yaml`** next to `Chart.yaml` (same directory — checked into Git):

- **`hub.environment`**, **`hub.site`**, **`hub.clusterName`** — select **`hub-clusters/day2/99-environments/<environment>/<site>/<clusterName>/values.yaml`** for every Day 2 Helm child Application (`helm.valueFiles`).
- **`repoURL`** / **`targetRevision`** — should match **`hub-clusters/day2/app-of-apps/values.yaml`** used when bootstrapping the root Application.

The root Application syncs this chart with **`helm.valueFiles: [values.yaml]`** (see `rootApp.helmValueFiles` in app-of-apps).

## ACM policies Application

**`acmPolicies.enabled`** controls rendering of **`app-acm-policies-<clusterName>`**, with `spec.source.path: spoke-clusters/<hub...>/policies` (Kustomize at that path, not this chart). Set **`acmPolicies.enabled: false`** if you manage policy Applications elsewhere.

## Index (templates)

| Template | `spec.source.path` | Child chart `releaseName` |
|----------|-------------------|---------------------------|
| `application-operator-installations.yaml` | `hub-clusters/day2/applications/operator-installations` | `operator-installations` |
| `application-policy-generator-gitops-patch.yaml` | `hub-clusters/day2/applications/policy-generator-gitops-patch` | `policy-generator-gitops-patch` |
| `application-ztp-configuration.yaml` | `hub-clusters/day2/applications/ztp-configuration` | `ztp-configuration` |
| `application-ztp-disconnected-configuration.yaml` | `hub-clusters/day2/applications/ztp-disconnected-configuration` | `ztp-disconnected-configuration` |
| `application-gitops-repos-config.yaml` | `hub-clusters/day2/applications/gitops-repos-config` | `gitops-repos-config` |
| `application-hub-platform-day2.yaml` | `hub-clusters/day2/applications/hub-platform-day2` | `hub-platform-day2` |
| `application-tekton-ztp.yaml` | `cluster-automation/spoke-automation/ztp-pipeline` | `tekton-ztp-pipeline` |
| `application-tekton-bulk-ztp.yaml` | `cluster-automation/spoke-automation/bulk-ztp-pipeline` | `tekton-bulk-ztp-pipeline` |
| `application-tekton-mirror.yaml` | `cluster-automation/spoke-automation/mirror-pipeline` | `tekton-mirror-pipeline` |
| `application-acm-policies.yaml` | `spoke-clusters/.../policies` (from `hub.*`) | n/a (Kustomize) |

## Local render

```bash
helm template mgd ./hub-clusters/day2/managed-applications -f hub-clusters/day2/managed-applications/values.yaml
```

See also [../99-environments/README.md](../99-environments/README.md) for what belongs in the per-hub `values.yaml` file.
