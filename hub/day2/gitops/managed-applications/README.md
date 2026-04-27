# Day 2 Managed Applications

## Purpose

This folder contains child OpenShift GitOps `Application` manifests synced by the root app.

## Apps

| Manifest | `spec.source.path` (chart in repo) | Helm `releaseName` (unchanged for continuity) |
|----------|-------------------------------------|------------------------------------------------|
| [application-ocp-operators-policy.yaml](application-ocp-operators-policy.yaml) | `hub/day2/helm/ocp-operators-policy` | `ocp-operators-policy` |
| [application-tekton-ztp.yaml](application-tekton-ztp.yaml) | `hub/day2/helm/ztp-pipeline` | `tekton-ztp-pipeline` |
| [application-tekton-bulk-ztp.yaml](application-tekton-bulk-ztp.yaml) | `hub/day2/helm/bulk-ztp-pipeline` | `tekton-bulk-ztp-pipeline` |
| [application-tekton-mirror.yaml](application-tekton-mirror.yaml) | `hub/day2/helm/mirror-pipeline` | `tekton-mirror-pipeline` |
| [application-acm-policies.yaml](application-acm-policies.yaml) | `spokes/policies` (Kustomize) | n/a |

## Before Sync

1. Set `repoURL` and `targetRevision` to your Git repo.
2. Ensure referenced secrets exist (GitHub token, registry secret, etc.).
3. Ensure PolicyGenerator support is enabled if syncing `spokes/policies`.
4. Set correct hub values file in each app `spec.source.helm.valueFiles`.
