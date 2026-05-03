{{/* Generated helpers for gblog chart */}}
{{- define "gblog.name" -}}
gblog
{{- end -}}

{{- define "gblog.fullname" -}}
{{- printf "%s-%s" (include "gblog.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
