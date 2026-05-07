# Chart: ztp-pipeline

Tekton **Pipeline** that renders **`cluster-automation/ztp-spoke`** manifests, opens a GitHub PR, optionally waits for merge, then watches provisioning on the hub.

## Flow

1. **`clone-repos`** — Shallow **`git clone`** (depth from **`tektonZtp.git.cloneDepth`**, default **50** so `HEAD:<path>` checks are reliable), resolve exactly one **`**/99-pipeline-values/<cluster>.yaml`**, write **`pipeline-values.path`** and **`fleet-context.env`** (`cluster-exists` hint).
2. **`get-mac-addresses`** — Ansible against **`localhost`** with **`-e @"${VALUES_FILE}"`** and **`--tags`**: **`dns_check`** (forward lookup **`api.<cluster>.<baseDomain>`** when **`baseDomain`** / **`base_domain`** is set), **`ping_mesh`** (ICMP to BMC hosts parsed from **`nodes[].bmcAddress`**), **`hardware_preflight`** (**`/redfish/v1/`**, Storage/Managers probes). **`ansible-galaxy collection install`** fails the step if collections cannot be installed.
3. **`generate-cluster-files`** — Validates **`cluster.name`** matches Pipeline **`cluster-name`**, requires **`nodes:`**, runs **`helm lint`** + **`helm template`** → **`manifests.yaml`** under **`manifest-output-dir/<cluster>/`**.
4. **`git-commit-and-mr`** — Branch/commit/push over HTTPS to **`github.com`** using **`GH_TOKEN`**, **`gh pr create`**, then resolves PR number via **`gh pr list --head`** (writes **`ztp-pr-number.txt`**).
5. **`wait-for-merge`** — Polls **`gh pr view`** until **`MERGED`** (skip with **`skip-wait-for-merge`**).
6. **`deploy-cluster`** — **`oc`** watch **ClusterInstance** Ready in namespace parsed from **`cluster.namespace`** in pipeline values; **`cluster-name`** param cross-checked (skip with **`skip-deploy-watch`**).

## Hub values (`tektonZtp`)

Set in **`hub-clusters/day2/99-environments/<env>/<site>/<hub>/values.yaml`**:

- **`git.cloneDepth`** — clone depth for Git history when detecting modify vs add paths.
- **`images`** — `git`, `ansible`, `helm`, `alpineTools`, `cli`.
- **`waitForMerge`** / **`deployWatch`** — polling intervals and timeouts.
- **`github.secretName`** / **`secretKey`** — PAT for **`gh`** and git HTTPS push.

Pipeline values for Ansible DNS checks: optional **`baseDomain`** or **`base_domain`** at top level of **`99-pipeline-values/<cluster>.yaml`**.

## GitOps

- Chart: **`cluster-automation/spoke-automation/ztp-pipeline/`**
- Application template: [application-tekton-ztp.yaml](../../../hub-clusters/day2/managed-applications/templates/application-tekton-ztp.yaml)

## Local render

```bash
helm template tekton-ztp-pipeline ./cluster-automation/spoke-automation/ztp-pipeline \
  -f hub-clusters/day2/99-environments/dev/east/dev-hub-east-1/values.yaml | oc apply -f -
```

## Related

- Render chart: [../../ztp-spoke/README.md](../../ztp-spoke/README.md)
- Per-spoke values: `spoke-clusters/<env>/<site>/<hub>/99-pipeline-values/README.md`
