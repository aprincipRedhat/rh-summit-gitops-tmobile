# Chart: ztp-pipeline

Tekton Pipeline: clone → detect replacement → Ansible preflight (DNS, hardware, Redfish MAC discovery) → `helm template` → GitHub PR → wait merge → watch provisioning → optional post-deploy validation.

## Normal flow

```mermaid
flowchart TD
    A([clone-repos]) --> B([detect-node-replacement])
    B -->|replacement-flow=none| C([preflight-sdn\nHTTP health check])
    C --> D([discover-node-network\nAnsible: DNS · hardware · Redfish MAC])
    D --> E([preflight-network\nping mesh])
    E --> F([manual-approval-gate\nConfigMap gate])
    F --> G([generate-cluster-files\nexpand inventory · helm template])
    G --> H([git-commit-and-mr\nGitHub PR])
    H --> I([wait-for-merge\npoll PR state])
    I --> J([deploy-cluster\nwatch ClusterInstance/ACI])
    J --> K([post-deploy-validation\nClusterOperators · kube-burner])
```

## Replacement flow

When `detect-node-replacement` emits `replacement-flow=full`, all normal-flow tasks are skipped and this path runs instead:

```mermaid
flowchart TD
    A([clone-repos]) --> B([detect-node-replacement])
    B -->|replacement-flow=full| C([replacement-merge-pipeline-values\nmerge discovered-nodes overlay])
    C --> D([replacement-validate-marker\nvalidate replacementTarget host])
    D --> E([replacement-helm-suppress\nhelm template — omitMarkedNodes])
    E --> F([replacement-git-mr-suppress\nPR: suppress BMC slot])
    F --> G([replacement-wait-merge-suppress\npoll PR])
    G --> H([replacement-teardown\netcd manual gate · oc delete node · BMH])
    H --> I([replacement-discover-node-network\nAnsible MAC discovery for new node])
    I --> J([replacement-merge-render-final\nmerge · strip marker · helm template])
    J --> K([replacement-git-mr-final\nPR: full ClusterInstance])
    K --> L([replacement-wait-merge-final\npoll PR])
    L --> M([replacement-wait-hub-clusterinstance\nwait for Argo sync on hub])
    M --> N([replacement-deploy-watch\nwatch ClusterInstance Ready])
```

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

- `vault.secretName` — Secret in `openshift-pipelines` with `VAULT_ADDR`+`VAULT_TOKEN` for Ansible Vault reads.
- `images.kubeBurner` — optional kube-burner image.
- `manualApproval.timeoutSeconds`, `clusterValidation.timeoutSeconds` — gate/validation timeouts.

## Local render

```bash
helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```
