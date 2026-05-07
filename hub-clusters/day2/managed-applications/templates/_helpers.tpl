{{- define "managed-apps.repoURL" -}}
{{- .Values.repoURL -}}
{{- end -}}

{{- define "managed-apps.targetRevision" -}}
{{- .Values.targetRevision -}}
{{- end -}}

{{/*
Relative path from hub-clusters/day2/applications/<chart>/ to the per-hub values file.
*/}}
{{- define "managed-apps.hubValuesFromDay2App" -}}
../../99-environments/{{ .Values.hub.environment }}/{{ .Values.hub.site }}/{{ .Values.hub.clusterName }}/values.yaml
{{- end -}}

{{/*
Relative path from cluster-automation/spoke-automation/<pipeline>/ to the per-hub values file.
*/}}
{{- define "managed-apps.hubValuesFromClusterAutomation" -}}
../../../hub-clusters/day2/99-environments/{{ .Values.hub.environment }}/{{ .Values.hub.site }}/{{ .Values.hub.clusterName }}/values.yaml
{{- end -}}

{{- define "managed-apps.spokePoliciesPath" -}}
spoke-clusters/{{ .Values.hub.environment }}/{{ .Values.hub.site }}/{{ .Values.hub.clusterName }}/policies
{{- end -}}
