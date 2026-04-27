# Day 2 Managed Applications

## Purpose

This folder contains child OpenShift GitOps `Application` manifests synced by the root app.

## Apps

- `application-ocp-operators-policy.yaml`
- `application-tekton-ztp.yaml`
- `application-tekton-bulk-ztp.yaml`
- `application-tekton-mirror.yaml`
- `application-acm-policies.yaml`

## Before Sync

1. Set `repoURL` and `targetRevision` to your Git repo.
2. Ensure referenced secrets exist (GitHub token, registry secret, etc.).
3. Ensure PolicyGenerator support is enabled if syncing `spokes/policies`.
4. Set correct hub values file in each app `spec.source.helm.valueFiles`.
