{{- define "tekton.oseToolsImage" -}}
registry.redhat.io/openshift4/ose-tools-rhel9:v4.16
{{- end -}}

{{- define "tekton.ansibleEEImage" -}}
registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest
{{- end -}}
