{{- define "tekton.oseToolsImage" -}}
registry.redhat.io/openshift4/ose-tools-rhel9:v4.20
{{- end -}}

{{/*
ztpToolsImage: ose-tools-rhel9 + helm. Override tektonZtp.images.ztpTools in hub-env-values
once custom-container-images/ose-ztp-tools is built and pushed to your mirror registry.
Falls back to base ose-tools-rhel9 (helm is bootstrapped at runtime in the step script).
*/}}
{{- define "tekton.ztpToolsImage" -}}
{{- dig "tektonZtp" "images" "ztpTools" "" (fromJson (toJson .Values)) | default (include "tekton.oseToolsImage" .) -}}
{{- end -}}

{{- define "tekton.ansibleEEImage" -}}
registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest
{{- end -}}
