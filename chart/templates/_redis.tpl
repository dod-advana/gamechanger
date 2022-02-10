
{{- define "app.redis.host" -}}
  {{- if eq .Values.redis.enabled true -}}
    {{- template "app.redis.fullname" . -}}
  {{- else -}}
    {{- if eq .Values.externalRedis.sentinel.enabled true -}}
        {{- .Values.externalRedis.sentinel.hosts -}}/{{- .Values.externalRedis.sentinel.masterSet -}}
    {{- else -}}
        {{- .Values.externalRedis.host -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "app.redis.port" -}}
  {{- if eq .Values.redis.enabled true -}}
    {{- printf "%s" "6379" -}}
  {{- else -}}
    {{- .Values.externalRedis.port -}}
  {{- end -}}
{{- end -}}

{{- define "app.redis.coreDatabaseIndex" -}}
  {{- if eq .Values.redis.enabled true -}}
    {{- printf "%s" "0" }}
  {{- else -}}
    {{- .Values.externalRedis.coreDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{/*
Return whether Redis&trade; uses password authentication or not
*/}} 
{{- define "app.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "app.redis.rawPassword" -}}
  {{- if and (not .Values.redis.enabled) .Values.externalRedis.password -}}
    {{- .Values.externalRedis.password -}}
  {{- end -}}
  {{- if and .Values.redis.enabled .Values.redis.auth.password .Values.redis.auth.enabled -}}
    {{- .Values.redis.auth.password -}}
  {{- end -}}
{{- end -}}

{{- define "app.redis.escapedRawPassword" -}}
  {{- if (include "app.redis.rawPassword" . ) -}}
    {{- include "app.redis.rawPassword" . | urlquery | replace "+" "%20" -}}
  {{- end -}}
{{- end -}}

{{- define "app.redisForCore" -}}
  {{- if eq .Values.externalRedis.sentinel.enabled false -}}
    {{- if (include "app.redis.escapedRawPassword" . ) -}}
      {{- printf "redis://redis:%s@%s:%s/%s" (include "app.redis.escapedRawPassword" . ) (include "app.redis.host" . ) (include "app.redis.port" . ) (include "app.redis.coreDatabaseIndex" . ) -}}
    {{- else -}}
      {{- printf "redis://%s:%s/%s" (include "app.redis.host" . ) (include "app.redis.port" . ) (include "app.redis.coreDatabaseIndex" . ) -}}
    {{- end -}}
  {{- else -}}
    {{- if (include "app.redis.escapedRawPassword" . ) -}}
      {{- printf "redis+sentinel://redis:%s@%s/%s" (include "app.redis.escapedRawPassword" . ) (include "app.redis.host" . ) (include "app.redis.coreDatabaseIndex" . ) -}}
    {{- else -}}
      {{- printf "redis+sentinel://%s/%s" (include "app.redis.host" . ) (include "app.redis.coreDatabaseIndex" . ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}