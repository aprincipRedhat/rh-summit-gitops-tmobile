# Chart: mirror-pipeline

Tekton Pipeline that runs `oc-mirror` v2 to sync images from a source registry to a destination registry, then (unless `skip-git-sync=true`) merges the generated IDMS/ITMS into the hub `hub-env-values` file and opens a GitHub PR. After merge, ArgoCD re-applies `ztp-disconnected-configuration`.

Optionally also writes a multi-doc IDMS/ITMS bundle to `spoke-clusters/.../policies/manifests/oc-mirror-idms-itms.yaml` for ACM policy distribution.

## Runner image

Build from `custom-container-images/oc-mirror` (based on `ose-tools-rhel9:v4.20`, includes `oc-mirror` v2, `yq`, `jq`, `gh`, `git`) and push to your registry. Using the cluster's internal registry:

```bash
# Create BuildConfig and build
oc new-build --strategy=docker --binary --name=oc-mirror-runner -n openshift-pipelines
oc patch buildconfig oc-mirror-runner -n openshift-pipelines \
  --type=merge -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath":"Containerfile"}}}}'
oc start-build oc-mirror-runner \
  --from-dir=custom-container-images/oc-mirror/ \
  --follow -n openshift-pipelines
```

The image lands at `image-registry.openshift-image-registry.svc:5000/openshift-pipelines/oc-mirror-runner:latest`.

## Required secrets

### Registry auth

Create a secret with Docker credentials for both the source registry (`registry.redhat.io`) and the destination registry. When using the internal registry, include a service account token:

```bash
SA_TOKEN=$(oc create token pipeline-oc-mirror -n openshift-pipelines --duration=24h)
PULL=$(oc get secret pull-secret -n openshift-config -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)

python3 -c "
import json, base64, sys
pull = json.loads('''${PULL}''')
token = '${SA_TOKEN}'
auth = base64.b64encode(f'serviceaccount:{token}'.encode()).decode()
for r in ['image-registry.openshift-image-registry.svc:5000',
          'default-route-openshift-image-registry.apps.<cluster-domain>']:
    pull.setdefault('auths', {})[r] = {'auth': auth}
print(json.dumps(pull))
" > /tmp/merged-auth.json

oc create secret generic mirror-registry-auth \
  --from-file=.dockerconfigjson=/tmp/merged-auth.json \
  --type=kubernetes.io/dockerconfigjson \
  -n openshift-pipelines
```

### GitHub token

Reuse the existing token secret or create one:

```bash
oc create secret generic github-tekton-token \
  --from-literal=token=<your-github-pat> \
  -n openshift-pipelines
```

Ensure `tektonMirror.github.secretName` and `tektonMirror.github.secretKey` in hub values match.

## Shared workspace PVC

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mirror-pipeline-shared
  namespace: openshift-pipelines
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 15Gi
EOF
```

## Hub values (`tektonMirror`)

```yaml
tektonMirror:
  pipeline:
    mirrorImage: image-registry.openshift-image-registry.svc:5000/openshift-pipelines/oc-mirror-runner:latest
  github:
    secretName: github-tekton-token
    secretKey: token
  imageSetConfiguration: |
    kind: ImageSetConfiguration
    apiVersion: mirror.openshift.io/v2alpha1
    mirror:
      platform:
        channels:
          - name: stable-4.20
            type: ocp
            minVersion: 4.20.21
            maxVersion: 4.20.21
      additionalImages:
        - name: registry.redhat.io/ubi9/ubi-minimal:latest
  gitSync:
    gitopsRepoUrl: https://github.com/<org>/<repo>.git
    githubRepoSlug: <org>/<repo>
    gitRevision: main
    gitBaseBranch: main
    hubValuesRelativePath: hub-clusters/day2/hub-env-values/<env>/<site>/<hub>/values.yaml
    policyManifestRelativePath: spoke-clusters/<env>/<site>/<hub>/policies/manifests/oc-mirror-idms-itms.yaml
```

### Destination registry

When using the OpenShift internal registry, pass the bare registry host (no namespace). oc-mirror v2 preserves the source image org as the project:

- `registry.redhat.io/ubi9/ubi-minimal` → `<registry>/ubi9/ubi-minimal`
- OCP release components → `<registry>/openshift/release:<tag>` (oc-mirror v2 always uses `openshift/release` for platform content)

Projects must exist and the pipeline SA must have push access:

```bash
oc new-project ubi9

# openshift namespace already exists; grant push rights
oc policy add-role-to-user system:image-builder \
  system:serviceaccount:openshift-pipelines:pipeline-oc-mirror \
  -n openshift
```

For external registries (Quay, Harbor) pass the full registry URL with namespace.

## Running the pipeline

### Test (oc-mirror only, no git sync)

```bash
oc create -f - <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: mirror-test-
  namespace: openshift-pipelines
spec:
  pipelineRef:
    name: ocp-registry-mirror
  params:
    - name: dest-registry
      value: "image-registry.openshift-image-registry.svc:5000"
    - name: skip-git-sync
      value: "true"
  workspaces:
    - name: imageset
      configMap:
        name: mirror-imageset-configuration
    - name: registry-auth
      secret:
        secretName: mirror-registry-auth
    - name: shared
      persistentVolumeClaim:
        claimName: mirror-pipeline-shared
EOF
```

### Full run (mirror + git sync + PR)

```bash
oc create -f - <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: mirror-full-
  namespace: openshift-pipelines
spec:
  pipelineRef:
    name: ocp-registry-mirror
  params:
    - name: dest-registry
      value: "image-registry.openshift-image-registry.svc:5000"
    - name: skip-git-sync
      value: "false"
  workspaces:
    - name: imageset
      configMap:
        name: mirror-imageset-configuration
    - name: registry-auth
      secret:
        secretName: mirror-registry-auth
    - name: shared
      persistentVolumeClaim:
        claimName: mirror-pipeline-shared
EOF
```

## oc-mirror v2 flags

The pipeline uses these flags for oc-mirror v2:

- `--v2` — required in OCP 4.20 (becomes default in 4.21)
- `--workspace file://<path>` — controls where IDMS/ITMS outputs land (`<workspace>/working-dir/cluster-resources/`)
- `--dest-tls-verify=false` — skip TLS verification for the destination registry
- Use `extra-flags` param for additional flags (e.g. `--dry-run`, `--since 2024-01-01`)
