#!/usr/bin/env bash
# Seed Vault with fake BMC credentials for the fake-bmc test server.
# Run once after deploying manifests.yaml.
#
# Usage:
#   export VAULT_ADDR=https://vault.example.com:8200
#   export VAULT_TOKEN=<your-root-or-admin-token>
#   bash seed-vault.sh

set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:?Set VAULT_ADDR}"
VAULT_TOKEN="${VAULT_TOKEN:?Set VAULT_TOKEN}"

# Must match vault.bmcCredentialsVaultPathPattern in 99-pipeline-values/<cluster>.yaml
# Pattern: vault-root/data/dev/east/dev-hub-east-1/bmc/%s
# For master-0:
BMC_PATH="vault-root/data/dev/east/dev-hub-east-1/bmc/master-0"

echo "Seeding Vault at ${VAULT_ADDR} path: ${BMC_PATH}"

curl -fsSL \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  --data '{"data": {"username": "admin", "password": "redfish"}}' \
  "${VAULT_ADDR}/v1/${BMC_PATH}"

echo ""
echo "Done. Vault secret: ${BMC_PATH}"
echo "  username: admin"
echo "  password: redfish"
