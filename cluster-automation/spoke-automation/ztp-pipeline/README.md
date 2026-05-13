# Chart: ztp-pipeline

Tekton Pipeline: clone → detect replacement → Ansible preflight (DNS, hardware, Redfish MAC discovery) → `helm template` → GitHub PR → wait merge → watch provisioning → optional post-deploy validation.

## Pipeline flow

1. **`clone-repos`** — shallow clone, resolve `**/99-pipeline-values/<cluster>.yaml`, write `fleet-context.env`.
2. **`detect-node-replacement`** — emit `replacement-flow=none` or `full`.
3. **`preflight-sdn`** — HTTP health check when `run-sdn-prechecks=true`. Skipped on replacement.
4. **`discover-node-network`** — Ansible (`files/ansible/`): DNS, hardware/Redfish, MAC discovery. Reads `VAULT_ADDR`/`VAULT_TOKEN` from optional Secret (`tektonZtp.vault.secretName`), queries Redfish for NIC MACs, writes `discovered-nodes.yaml`.
5. **`preflight-network`** — ping / connectivity when `run-network-connectivity-test=true`.
6. **`manual-approval-gate`** — ConfigMap `ztp-manual-<cluster>-approval` gating when `skip-manual-approval-gate=false`.
7. **`generate-cluster-files`** — merge discovered nodes into pipeline values, `expand_node_inventory.py`, `helm lint` + `helm template` → `manifests.yaml`.
8. **`git-commit-and-mr`** / **`wait-for-merge`** — GitHub PR (`GH_TOKEN` Secret).
9. **`deploy-cluster`** — watch `ClusterInstance` Ready + `AgentClusterInstall` status.
10. **`post-deploy-validation`** — optional ClusterOperator / MCP checks + kube-burner.

When `replacement-flow=full`, replacement tasks run instead: suppress MR, etcd gate, teardown, MAC discovery, final MR, hub `ClusterInstance` sync, deploy watch.

## Parameters

| Param | Default | Meaning |
|-------|---------|---------|
| `run-sdn-prechecks` | false | HTTP SDN health check |
| `run-hardware-validation` | true | Ansible hardware/Redfish tags |
| `run-network-connectivity-test` | true | Ansible ping |
| `run-mac-discovery` | true | Redfish MAC discovery (requires Vault + BMC access) |
| `skip-manual-approval-gate` | true | Set false to require ConfigMap approval |
| `run-post-deploy-validation` | false | Spoke ClusterOperator / MCP checks |
| `run-kube-burner-tests` | false | Smoke workload (requires `tektonZtp.images.kubeBurner`) |
| `replacement-execute-destructive` | false | Allow `oc delete` node/BMH on replacement path |
| `pipeline-values-overlay-path` | "" | Repo-relative YAML deep-merged on top of base pipeline values before Ansible/Helm run |

## Hub values (`tektonZtp`)

Set in `hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml`:

- `vault.secretName` — Secret in `openshift-pipelines` with `VAULT_ADDR`+`VAULT_TOKEN` for Ansible Vault reads. Defaults to `vault-tekton-credentials` (populated by `acm-hub-vault-credential-sync`).
- `images.kubeBurner` — optional kube-burner image.
- `manualApproval.timeoutSeconds`, `clusterValidation.timeoutSeconds` — gate/validation timeouts.

## Local render

```bash
helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
