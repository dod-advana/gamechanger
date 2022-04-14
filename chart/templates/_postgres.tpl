
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app.postgresql.host" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{ include "postgresql.primary.svc.headless" .Subcharts.postgresql }}
  {{- else -}}
    {{- .Values.postgresql.host -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.port" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{ include "postgresql.service.port" .Subcharts.postgresql }}
  {{- else -}}
    {{- .Values.postgresql.port -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.username" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{- include "postgresql.username" .Subcharts.postgresql -}}
  {{- else -}}
    {{- .Values.postgresql.user -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.secretName" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{- include "postgresql.secretName" .Subcharts.postgresql -}}
  {{- else -}}
    {{- .Values.postgresql.existingSecret -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.password" -}}
{{- if not (empty .Values.postgresql.password) }}
    {{- .Values.postgresql.password -}}
{{- else -}}
    {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "app.postgresql.secretName" .) "Length" 10 "Key" "postgres-password")  -}}
{{- end -}}
{{- end -}}