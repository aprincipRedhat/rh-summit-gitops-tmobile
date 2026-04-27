# Day 2 GitOps

## Purpose

This folder contains OpenShift GitOps assets for Day 2.

## Key Paths

| Path | Purpose |
|------|---------|
| `bootstrap/` | Helm chart that creates root `Application` and `ApplicationSet`. |
| `managed-applications/` | Child `Application` manifests synced by the root app. |
| `policy-generator-plugin/` | Repo-server patch guidance for PolicyGenerator support. |
| `../helm/` | Day 2 Helm charts: `ocp-operators-policy/`, `ztp-pipeline/`, `bulk-ztp-pipeline/`, `mirror-pipeline/`. |

Use `bootstrap/` first, then let root app sync `managed-applications/`.
