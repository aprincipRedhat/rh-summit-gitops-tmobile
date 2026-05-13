{{- define "ztp-spoke.bmcDestinationSecretName" -}}
{{- printf "bmc-%s-%s" .clusterName .hostname -}}
{{- end }}
