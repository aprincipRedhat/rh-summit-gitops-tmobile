{{- define "ztp.nodeReplacementTasks" }}
    - name: replacement-merge-pipeline-values
      runAfter: [detect-node-replacement]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      taskSpec:
        workspaces:
          - name: shared
        steps:
          - name: merge
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              BASE="$(cat "${ROOT}/pipeline-values.path")"
              MERGED="${ROOT}/merged-pipeline-values.yaml"
              DISC="${ROOT}/discovered-nodes.yaml"
              SCRIPT="${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/merge_pipeline_values.py"
              rm -f "${MERGED}"
              if [ -f "$DISC" ]; then
                apk add --no-cache python3 py3-yaml
                python3 "$SCRIPT" "$BASE" "$DISC" "$MERGED"
              else
                cp "$BASE" "$MERGED"
              fi
              apk add --no-cache python3 py3-yaml
              python3 "${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/expand_node_inventory.py" "$MERGED"
              echo "$MERGED" > "${ROOT}/merged-pipeline-values.path"

    - name: replacement-validate-marker
      runAfter: [replacement-merge-pipeline-values]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      taskSpec:
        workspaces:
          - name: shared
        steps:
          - name: validate
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              MERGED="$(cat "${ROOT}/merged-pipeline-values.path")"
              apk add --no-cache python3 py3-yaml
              SCRIPT="${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/validate_replacement_marker.py"
              HOST=$(python3 "$SCRIPT" "$MERGED")
              printf '%s' "$HOST" > "${ROOT}/replacement-target-host.txt"

    - name: replacement-helm-suppress
      runAfter: [replacement-validate-marker]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: ztp-chart-relative-path
          value: $(params.ztp-chart-relative-path)
        - name: manifest-output-dir
          value: $(params.manifest-output-dir)
        - name: skip-suppress-mr
          value: $(params.skip-replacement-suppress-mr)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: ztp-chart-relative-path
          - name: manifest-output-dir
          - name: skip-suppress-mr
        steps:
          - name: helm-suppress
            image: {{ .Values.tektonZtp.images.helm | quote }}
            script: |
              #!/bin/sh
              set -eu
              if [ "$(params.skip-suppress-mr)" = "true" ]; then exit 0; fi
              ROOT="$(workspaces.shared.path)"
              cd "${ROOT}/src"
              VALUES="$(cat "${ROOT}/merged-pipeline-values.path")"
              OUT="$(params.manifest-output-dir)/$(params.cluster-name)"
              mkdir -p "$OUT"
              CHART="./$(params.ztp-chart-relative-path)"
              printf '%s\n' "nodeReplacement:" "  omitMarkedNodes: true" > "${ROOT}/suppress-overlay.yaml"
              helm lint "$CHART" -f "$VALUES" -f "${ROOT}/suppress-overlay.yaml"
              helm template "$(params.cluster-name)" "$CHART" -f "$VALUES" -f "${ROOT}/suppress-overlay.yaml" \
                > "${OUT}/manifests.yaml"

    - name: replacement-git-mr-suppress
      runAfter: [replacement-helm-suppress]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: manifest-output-dir
          value: $(params.manifest-output-dir)
        - name: gitops-repo-url
          value: $(params.gitops-repo-url)
        - name: git-base-branch
          value: $(params.git-base-branch)
        - name: github-repo-slug
          value: $(params.github-repo-slug)
        - name: git-user-name
          value: $(params.git-user-name)
        - name: git-user-email
          value: $(params.git-user-email)
        - name: skip-suppress-mr
          value: $(params.skip-replacement-suppress-mr)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: manifest-output-dir
          - name: gitops-repo-url
          - name: git-base-branch
          - name: github-repo-slug
          - name: git-user-name
          - name: git-user-email
          - name: skip-suppress-mr
        steps:
          - name: push-suppress-pr
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            env:
              - name: GH_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.tektonZtp.github.secretName }}
                    key: {{ .Values.tektonZtp.github.secretKey }}
            script: |
              #!/bin/sh
              set -eu
              if [ "$(params.skip-suppress-mr)" = "true" ]; then : > "$(workspaces.shared.path)/ztp-pr-number-suppress.txt"; exit 0; fi
              apk add --no-cache git github-cli bash
              ROOT="$(workspaces.shared.path)"
              cd "${ROOT}/src"
              git config user.name "$(params.git-user-name)"
              git config user.email "$(params.git-user-email)"
              BRANCH="ztp-nr-suppress-$(params.cluster-name)-$(date +%s)"
              git checkout -b "$BRANCH"
              git add "$(params.manifest-output-dir)/$(params.cluster-name)"
              git commit -m "chore(ztp): suppress ClusterInstance node (omitMarkedNodes)" || { git status; exit 1; }
              REMOTE="$(params.gitops-repo-url)"
              OWNER_REPO=$(echo "$REMOTE" | sed -e 's|https://github.com/||' -e 's|\.git$||')
              git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${OWNER_REPO}.git"
              git push -u origin "$BRANCH"
              export GH_TOKEN
              gh pr create --repo "$(params.github-repo-slug)" --base "$(params.git-base-branch)" --head "$BRANCH" \
                --title "$(params.pr-title-replacement-suppress) $(params.cluster-name)" \
                --body "ZTP node replacement: suppress BMC slot before etcd/node teardown."
              PR_NUM=$(gh pr list --head "$BRANCH" --repo "$(params.github-repo-slug)" --json number --jq '.[0].number' 2>/dev/null || true)
              echo "${PR_NUM:-}" > "${ROOT}/ztp-pr-number-suppress.txt"

    - name: replacement-wait-merge-suppress
      runAfter: [replacement-git-mr-suppress]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: github-repo-slug
          value: $(params.github-repo-slug)
        - name: skip-wait-merge-suppress
          value: $(params.skip-replacement-wait-merge-suppress)
        - name: skip-suppress-mr
          value: $(params.skip-replacement-suppress-mr)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: github-repo-slug
          - name: skip-wait-merge-suppress
          - name: skip-suppress-mr
        steps:
          - name: poll
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            env:
              - name: GH_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.tektonZtp.github.secretName }}
                    key: {{ .Values.tektonZtp.github.secretKey }}
            script: |
              #!/bin/sh
              set -eu
              if [ "$(params.skip-suppress-mr)" = "true" ] || [ "$(params.skip-wait-merge-suppress)" = "true" ]; then exit 0; fi
              apk add --no-cache github-cli bash
              ROOT="$(workspaces.shared.path)"
              export GH_TOKEN
              POLL={{ .Values.tektonZtp.waitForMerge.pollIntervalSeconds | default 30 }}
              MAX_ITER=$(( {{ .Values.tektonZtp.waitForMerge.timeoutSeconds | default 7200 }} / POLL ))
              PR_NUM=$(cat "${ROOT}/ztp-pr-number-suppress.txt" 2>/dev/null || echo "")
              i=0
              while [ "$i" -lt "$MAX_ITER" ]; do
                STATE=$(gh pr view "$PR_NUM" --repo "$(params.github-repo-slug)" --json state --jq .state)
                [ "$STATE" = "MERGED" ] && exit 0
                [ "$STATE" = "CLOSED" ] && exit 1
                i=$((i + 1))
                sleep "$POLL"
              done
              exit 1

    - name: replacement-teardown
      runAfter: [replacement-wait-merge-suppress]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: execute-destructive
          value: $(params.replacement-execute-destructive)
        - name: skip-etcd-manual-gate
          value: $(params.replacement-skip-etcd-manual-gate)
        - name: spoke-kubeconfig-secret-name
          value: $(params.spoke-kubeconfig-secret-name)
        - name: spoke-kubeconfig-secret-namespace
          value: $(params.spoke-kubeconfig-secret-namespace)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: execute-destructive
          - name: skip-etcd-manual-gate
          - name: spoke-kubeconfig-secret-name
          - name: spoke-kubeconfig-secret-namespace
        steps:
          - name: etcd-then-node-conditional
            image: {{ .Values.tektonZtp.images.cli | quote }}
            script: |
              #!/bin/bash
              set -euo pipefail
              ROOT="$(workspaces.shared.path)"
              VALUES="$(cat "${ROOT}/merged-pipeline-values.path")"
              CLUSTER="$(params.cluster-name)"
              NODE=$(cat "${ROOT}/replacement-target-host.txt")
              CL_NS=$(awk '/^cluster:/{blk=1;next} blk&&/^[^[:space:]]/{exit} blk&&/^  namespace:/{gsub(/"/,"",$2); print $2; exit}' "$VALUES")
              SEC_NS="$(params.spoke-kubeconfig-secret-namespace)"
              [ -z "${SEC_NS}" ] && SEC_NS="${CL_NS}"
              SEC_NAME="$(params.spoke-kubeconfig-secret-name)"
              [ -z "${SEC_NAME}" ] && SEC_NAME="${CLUSTER}-admin-kubeconfig"
              oc get secret "${SEC_NAME}" -n "${SEC_NS}" -o jsonpath='{.data.kubeconfig}' | base64 -d > "${ROOT}/spoke.kubeconfig"
              export KUBECONFIG="${ROOT}/spoke.kubeconfig"
              CP=$(oc get node "${NODE}" -o jsonpath='{.metadata.labels.node-role\.kubernetes\.io/control-plane}' 2>/dev/null || true)
              MAST=$(oc get node "${NODE}" -o jsonpath='{.metadata.labels.node-role\.kubernetes\.io/master}' 2>/dev/null || true)
              if [ "${CP}" = "true" ] || [ "${MAST}" = "true" ]; then
                if [ "$(params.skip-etcd-manual-gate)" != "true" ]; then
                  CM="ztp-node-replacement-etcd-${CLUSTER}"
                  NS=openshift-pipelines
                  oc create configmap "${CM}" --from-literal=approved=false -n "${NS}" --dry-run=client -o yaml | oc apply -f -
                  END=$(( $(date +%s) + {{ .Values.tektonZtp.nodeReplacement.etcdManualGate.timeoutSeconds | default 7200 }} ))
                  while true; do
                    [ "$(date +%s)" -ge "$END" ] && { echo etcd gate timeout >&2; exit 1; }
                    ST=$(oc get configmap "${CM}" -n "${NS}" -o jsonpath='{.data.approved}' 2>/dev/null || echo "")
                    [ "$ST" = "true" ] && break
                    sleep 15
                  done
                fi
              fi
              if [ "$(params.execute-destructive)" != "true" ]; then
                echo "replacement-execute-destructive!=true — skipping deletes"
                exit 0
              fi
              unset KUBECONFIG
              PROV=$(oc get baremetalhost "${NODE}" -n "${CL_NS}" -o jsonpath='{.status.provisioning.state}' 2>/dev/null || echo "")
              echo "BMH ${NODE} provisioning.state=${PROV}"
              if echo "$PROV" | grep -qi deprovision; then
                echo "BMH already deprovisioning — skipping oc delete node"
                exit 0
              fi
              export KUBECONFIG="${ROOT}/spoke.kubeconfig"
              oc delete node "${NODE}" --wait=true
              for _ in $(seq 1 120); do
                if ! oc get machines.machine.openshift.io -n openshift-machine-api -o jsonpath='{range .items[*]}{.status.nodeRef.name}{"\n"}{end}' 2>/dev/null | grep -qx "${NODE}"; then break; fi
                sleep 10
              done
              unset KUBECONFIG
              oc delete baremetalhost "${NODE}" -n "${CL_NS}" --wait=true 2>/dev/null || true

    - name: replacement-discover-node-network
      runAfter: [replacement-teardown]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: skip-ansible
          value: $(params.skip-ansible)
        - name: ansible-tags
          value: $(params.ansible-tags)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: skip-ansible
          - name: ansible-tags
        volumes:
          - name: ansible-preflight-bundle
            configMap:
              name: {{ .Values.tektonZtp.ansible.preflightConfigMapName | quote }}
        steps:
          - name: ansible-mac
            image: {{ .Values.tektonZtp.images.ansible | quote }}
{{- if ((.Values.tektonZtp.vault | default dict).secretName | default "") }}
            envFrom:
              - secretRef:
                  name: {{ .Values.tektonZtp.vault.secretName | quote }}
{{- end }}
            volumeMounts:
              - name: ansible-preflight-bundle
                mountPath: /ansible-cm
                readOnly: true
            script: |
              #!/bin/bash
              set -euo pipefail
              if [[ "$(params.skip-ansible)" == "true" ]]; then exit 0; fi
              ROOT="$(workspaces.shared.path)"
              VALUES_FILE="$(cat "${ROOT}/pipeline-values.path")"
              TAG_OVERRIDE="$(params.ansible-tags)"
              export SKIP_MAC_DISCOVERY=false
              export MAC_DISCOVERY_OUTPUT="${ROOT}/discovered-nodes.yaml"
              if [[ -n "${TAG_OVERRIDE// }" ]]; then TAGS="${TAG_OVERRIDE}"
              else TAGS="dns,hardware,bmc,redfish,ping,mac-discovery"; fi
              export ANSIBLE_COLLECTIONS_PATH="${ROOT}/.ansible-collections"
              RESTORE=/tmp/ansible-preflight
              rm -rf "$RESTORE" && mkdir -p "$RESTORE"
              shopt -s nullglob
              for keypath in /ansible-cm/*; do
                base=$(basename "$keypath")
                rel=${base//__//}
                mkdir -p "$RESTORE/$(dirname "$rel")"
                cp "$keypath" "$RESTORE/$rel"
              done
              ansible-galaxy collection install -r "$RESTORE/requirements.yml" -p "$ANSIBLE_COLLECTIONS_PATH"
              ansible-playbook -i "localhost," -c local "$RESTORE/site.yml" \
                --tags "${TAGS}" \
                -e ansible_python_interpreter=/usr/bin/python3 \
                -e mac_discovery_output="${MAC_DISCOVERY_OUTPUT}" \
                -e @"${VALUES_FILE}"

    - name: replacement-merge-render-final
      runAfter: [replacement-discover-node-network]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: ztp-chart-relative-path
          value: $(params.ztp-chart-relative-path)
        - name: manifest-output-dir
          value: $(params.manifest-output-dir)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: ztp-chart-relative-path
          - name: manifest-output-dir
        steps:
          - name: merge-final
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              BASE="$(cat "${ROOT}/pipeline-values.path")"
              MERGED="${ROOT}/merged-pipeline-values.yaml"
              DISC="${ROOT}/discovered-nodes.yaml"
              SCRIPT="${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/merge_pipeline_values.py"
              rm -f "${MERGED}"
              if [ -f "$DISC" ]; then
                apk add --no-cache python3 py3-yaml
                python3 "$SCRIPT" "$BASE" "$DISC" "$MERGED"
              else
                cp "$BASE" "$MERGED"
              fi
              apk add --no-cache python3 py3-yaml
              python3 "${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/expand_node_inventory.py" "$MERGED"
              echo "$MERGED" > "${ROOT}/merged-pipeline-values.path"
          - name: strip-marker
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              MERGED="${ROOT}/merged-pipeline-values.yaml"
              apk add --no-cache python3 py3-yaml
              python3 "${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/strip_replacement_marker.py" "$MERGED"
          - name: helm-final
            image: {{ .Values.tektonZtp.images.helm | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              cd "${ROOT}/src"
              VALUES="$(cat "${ROOT}/merged-pipeline-values.path")"
              OUT="$(params.manifest-output-dir)/$(params.cluster-name)"
              mkdir -p "$OUT"
              CHART="./$(params.ztp-chart-relative-path)"
              helm lint "$CHART" -f "$VALUES"
              helm template "$(params.cluster-name)" "$CHART" -f "$VALUES" > "${OUT}/manifests.yaml"

    - name: replacement-git-mr-final
      runAfter: [replacement-merge-render-final]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: manifest-output-dir
          value: $(params.manifest-output-dir)
        - name: gitops-repo-url
          value: $(params.gitops-repo-url)
        - name: git-base-branch
          value: $(params.git-base-branch)
        - name: github-repo-slug
          value: $(params.github-repo-slug)
        - name: git-user-name
          value: $(params.git-user-name)
        - name: git-user-email
          value: $(params.git-user-email)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: manifest-output-dir
          - name: gitops-repo-url
          - name: git-base-branch
          - name: github-repo-slug
          - name: git-user-name
          - name: git-user-email
        steps:
          - name: push-final-pr
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            env:
              - name: GH_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.tektonZtp.github.secretName }}
                    key: {{ .Values.tektonZtp.github.secretKey }}
            script: |
              #!/bin/sh
              set -eu
              apk add --no-cache git github-cli bash
              ROOT="$(workspaces.shared.path)"
              cd "${ROOT}/src"
              git config user.name "$(params.git-user-name)"
              git config user.email "$(params.git-user-email)"
              BRANCH="ztp-nr-final-$(params.cluster-name)-$(date +%s)"
              git checkout -b "$BRANCH"
              git add "$(params.manifest-output-dir)/$(params.cluster-name)"
              git commit -m "feat(ztp): node replacement — full ClusterInstance after discovery" || { git status; exit 1; }
              REMOTE="$(params.gitops-repo-url)"
              OWNER_REPO=$(echo "$REMOTE" | sed -e 's|https://github.com/||' -e 's|\.git$||')
              git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${OWNER_REPO}.git"
              git push -u origin "$BRANCH"
              export GH_TOKEN
              gh pr create --repo "$(params.github-repo-slug)" --base "$(params.git-base-branch)" --head "$BRANCH" \
                --title "$(params.pr-title-replacement-final) $(params.cluster-name)" \
                --body "ZTP: post-replacement manifests (BMC unsuppressed / full render)."
              PR_NUM=$(gh pr list --head "$BRANCH" --repo "$(params.github-repo-slug)" --json number --jq '.[0].number' 2>/dev/null || true)
              echo "${PR_NUM:-}" > "${ROOT}/ztp-pr-number.txt"

    - name: replacement-wait-merge-final
      runAfter: [replacement-git-mr-final]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: github-repo-slug
          value: $(params.github-repo-slug)
        - name: skip-wait-merge-final
          value: $(params.skip-replacement-wait-merge-final)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: github-repo-slug
          - name: skip-wait-merge-final
        steps:
          - name: poll-final
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            env:
              - name: GH_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.tektonZtp.github.secretName }}
                    key: {{ .Values.tektonZtp.github.secretKey }}
            script: |
              #!/bin/sh
              set -eu
              [ "$(params.skip-wait-merge-final)" = "true" ] && exit 0
              apk add --no-cache github-cli bash
              ROOT="$(workspaces.shared.path)"
              export GH_TOKEN
              POLL={{ .Values.tektonZtp.waitForMerge.pollIntervalSeconds | default 30 }}
              MAX_ITER=$(( {{ .Values.tektonZtp.waitForMerge.timeoutSeconds | default 7200 }} / POLL ))
              PR_NUM=$(cat "${ROOT}/ztp-pr-number.txt" 2>/dev/null || echo "")
              i=0
              while [ "$i" -lt "$MAX_ITER" ]; do
                STATE=$(gh pr view "$PR_NUM" --repo "$(params.github-repo-slug)" --json state --jq .state)
                [ "$STATE" = "MERGED" ] && exit 0
                [ "$STATE" = "CLOSED" ] && exit 1
                i=$((i + 1))
                sleep "$POLL"
              done
              exit 1

    - name: replacement-wait-hub-clusterinstance
      runAfter: [replacement-wait-merge-final]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
        steps:
          - name: list-desired-hosts
            image: {{ .Values.tektonZtp.images.alpineTools | quote }}
            script: |
              #!/bin/sh
              set -eu
              ROOT="$(workspaces.shared.path)"
              MERGED="${ROOT}/merged-pipeline-values.yaml"
              apk add --no-cache python3 py3-yaml
              python3 "${ROOT}/src/cluster-automation/spoke-automation/ztp-pipeline/files/scripts/node_inventory.py" \
                hostnames "$MERGED" > "${ROOT}/desired-clusterinstance-hostnames.txt"
          - name: wait-sync
            image: {{ .Values.tektonZtp.images.cli | quote }}
            script: |
              #!/bin/bash
              set -euo pipefail
              ROOT="$(workspaces.shared.path)"
              MERGED="${ROOT}/merged-pipeline-values.yaml"
              WANT_FILE="${ROOT}/desired-clusterinstance-hostnames.txt"
              CLUSTER="$(params.cluster-name)"
              NS=$(awk '/^cluster:/{blk=1;next} blk&&/^[^[:space:]]/{exit} blk&&/^  namespace:/{gsub(/"/,"",$2); print $2; exit}' "$MERGED")
              mapfile -t WANT < <(grep -v '^[[:space:]]*$' "$WANT_FILE" 2>/dev/null || true)
              if [ "${#WANT[@]}" -eq 0 ]; then
                echo "No desired hostnames from merged values (node_inventory) — skipping hub wait"
                exit 0
              fi
              echo "Waiting for hub ClusterInstance to match Git after merge (Argo sync → unsuppress / new node)..."
              POLL={{ .Values.tektonZtp.deployWatch.pollIntervalSeconds | default 30 }}
              MAX_SEC={{ .Values.tektonZtp.nodeReplacement.hubSyncWaitSeconds | default 7200 }}
              START_TS=$(date +%s)
              while true; do
                NOW=$(date +%s)
                if [ $((NOW - START_TS)) -ge "$MAX_SEC" ]; then
                  echo "Timeout waiting for ClusterInstance to include desired hostnames" >&2
                  exit 1
                fi
                HAVE=$(oc get clusterinstance "$CLUSTER" -n "$NS" -o jsonpath='{range .spec.nodes[*]}{.hostName}{" "}{end}' 2>/dev/null || true)
                OK=true
                for h in "${WANT[@]}"; do
                  [ -z "$h" ] && continue
                  if ! echo " $HAVE " | grep -q " ${h} "; then
                    OK=false
                    break
                  fi
                done
                if [ "$OK" = true ]; then
                  echo "ClusterInstance lists desired hostnames: ${WANT[*]}"
                  exit 0
                fi
                echo "Waiting for hub ClusterInstance nodes (have: ${HAVE:-none})..."
                sleep "$POLL"
              done

    - name: replacement-deploy-watch
      runAfter: [replacement-wait-hub-clusterinstance]
      when:
        - input: $(tasks.detect-node-replacement.results.replacement-flow)
          operator: in
          values: ["full"]
      workspaces:
        - name: shared
          workspace: shared
      params:
        - name: cluster-name
          value: $(params.cluster-name)
        - name: skip-deploy-watch
          value: $(params.skip-replacement-deploy-watch)
      taskSpec:
        workspaces:
          - name: shared
        params:
          - name: cluster-name
          - name: skip-deploy-watch
        steps:
          - name: watch
            image: {{ .Values.tektonZtp.images.cli | quote }}
            script: |
              #!/bin/bash
              set -euo pipefail
              [ "$(params.skip-deploy-watch)" = "true" ] && exit 0
              ROOT="$(workspaces.shared.path)"
              VALUES_FILE="$(cat "${ROOT}/merged-pipeline-values.path")"
              CLUSTER="$(params.cluster-name)"
              NS=$(awk '/^cluster:/{blk=1;next} blk&&/^[^[:space:]]/{exit} blk&&/^  namespace:/{gsub(/"/,"",$2); print $2; exit}' "$VALUES_FILE")
              POLL={{ .Values.tektonZtp.deployWatch.pollIntervalSeconds | default 30 }}
              START_TS=$(date +%s)
              MAX_SEC={{ .Values.tektonZtp.deployWatch.timeoutSeconds | default 14400 }}
              while true; do
                NOW=$(date +%s)
                [ $((NOW - START_TS)) -ge "$MAX_SEC" ] && exit 1
                READY=$(oc get clusterinstance "$CLUSTER" -n "$NS" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
                [ "$READY" = "True" ] && exit 0
                sleep "$POLL"
              done
{{- end }}
