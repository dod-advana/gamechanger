
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.postgresql.fullname" -}}
{{- $name := default include "common.names.fullname" .Subcharts.postgres -}}
{{- printf "%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app.postgresql.host" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{ printf "%s.%s.svc.%s" (include "postgresql.primary.fullname" .Subcharts.postgresql) .Release.Namespace .Values.clusterDomain }}
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
{{- $name := default "postgres" .Values.postgresql.user -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{- default $name (include "postgresql.username" .Subcharts.postgresql)  -}}
  {{- else -}}
    {{- $name -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.secretName" -}}
  {{- if .Values.postgresql.asSubchart -}}
    {{- include "postgresql.secretName" .Subcharts.postgresql -}}
  {{- else -}}
    {{- .Values.postgresql.existingSecret -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.security.envVars" -}}
{{- if .Values.postgresql.asSubchart -}}
- name: POSTGRES_PASSWORD_UOT
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" .Subcharts.postgresql }}
      key: postgres-password
- name: POSTGRES_PASSWORD_GAME_CHANGER
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" .Subcharts.postgresql }}
      key: postgres-password
- name: POSTGRES_PASSWORD_GC_ORCHESTRATION
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" .Subcharts.postgresql }}
      key: postgres-password
- name: PG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" .Subcharts.postgresql }}
      key: postgres-password
{{- end -}}
{{- end -}}
