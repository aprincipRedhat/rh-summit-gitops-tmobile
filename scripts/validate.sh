#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
HUB_VALUES="${HUB_VALUES:-${ROOT}/hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml}"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm not found in PATH" >&2
  exit 1
fi

echo "Using hub values: ${HUB_VALUES}"

helm template validate-managed "${ROOT}/hub-clusters/day2/managed-applications" \
  -f "${ROOT}/hub-clusters/day2/managed-applications/values.yaml" >/dev/null

helm template validate-mirror "${ROOT}/cluster-automation/spoke-automation/mirror-pipeline" \
  -f "${HUB_VALUES}" >/dev/null

helm template validate-ztp "${ROOT}/cluster-automation/spoke-automation/ztp-pipeline" \
  -f "${HUB_VALUES}" >/dev/null

helm template validate-bulk "${ROOT}/cluster-automation/spoke-automation/bulk-ztp-pipeline" \
  -f "${HUB_VALUES}" >/dev/null

helm template validate-mirror-tt "${ROOT}/cluster-automation/spoke-automation/mirror-tenant-triggers" \
  -f "${HUB_VALUES}" >/dev/null

helm template validate-node-repl "${ROOT}/cluster-automation/spoke-automation/ztp-node-replacement" \
  -f "${HUB_VALUES}" >/dev/null

echo "helm template validation OK"
