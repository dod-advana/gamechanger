{{/*
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.redis.fullname" -}}
{{- $name := include "common.names.fullname" .Subcharts.redis -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app.redis.hosts" -}}
  {{- if .Values.redis.asSubchart -}}
    {{ printf "%s-master.%s.svc.%s" (include "app.redis.fullname" .) .Release.Namespace .Values.clusterDomain }}
    {{ printf "%s-replicas.%s.svc.%s" (include "app.redis.fullname" .) .Release.Namespace .Values.clusterDomain }} 
  {{- else -}}
    {{- .Values.redis.hosts -}}
  {{- end -}}
{{- end -}}

{{- define "app.redis.host" -}}
  {{- if .Values.redis.asSubchart -}}
    {{ printf "%s-master.%s.svc.%s" (include "app.redis.fullname" .) .Release.Namespace .Values.clusterDomain }}
  {{- else -}}
    {{- .Values.redis.hosts | first -}}
  {{- end -}}
{{- end -}}

{{- define "app.redis.port" -}}
  {{- if .Values.redis.asSubchart -}}
    {{- .Values.redis.master.service.ports.redis -}}
  {{- else -}}
    {{- .Values.redis.port -}}
  {{- end -}}
{{- end -}}

{{/*
Return whether Redis&trade; uses password authentication or not
*/}} 
{{- define "app.redis.auth.enabled" -}}
    {{.Values.redis.auth.enabled}}
{{- end -}}
{{/*
Return Redis&trade; password
*/}}
{{- define "app.redis.password" -}}
{{- if .Values.redis.asSubchart -}}
{{- include "redis.password" .Subchart.redis  -}}
{{- else if not (empty .Values.redis.auth.password) }}
{{- .Values.redis.auth.password -}}    
{{- end -}}
{{- end -}}


{{/*
Get the password secret.
*/}}
{{- define "app.redis.secretName" -}}
{{- if .Values.redis.asSubchart -}}
{{- include "redis.secretName" .Subchart.redis  -}}
{{- else -}}
{{- printf "%s" .Values.redis.auth.existingSecret -}}
{{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from Redis&trade; secret.
*/}}
{{- define "app.redis.secretPasswordKey" -}}
{{- if .Values.redis.asSubchart -}}
{{- include "redis.secretPasswordKey" .Subchart.redis  -}}
{{- else if and .Values.redis.auth.existingSecret .Values.redis.auth.existingSecretPasswordKey -}}
{{- printf "%s" .Values.redis.auth.existingSecretPasswordKey -}}
{{- end -}}
{{- end -}}