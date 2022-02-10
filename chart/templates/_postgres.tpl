
{{- define "app.postgresql.host" -}}
  {{- if eq .Values.postgresql.enabled true -}}
    {{- template "app.postgresql.fullname" . }}
  {{- else -}}
    {{- .Values.externalPostgresql.host -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.port" -}}
  {{- if eq .Values.postgresql.enabled true -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.externalPostgresql.port -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.username" -}}
  {{- if eq .Values.postgresql.enabled true -}}
    {{- .Values.postgresql.postgresqlUsername -}}
  {{- else -}}
    {{- .Values.externalPostgresql.user -}}
  {{- end -}}
{{- end -}}

{{- define "app.postgresql.rawPassword" -}}
  {{- if eq .Values.postgresql.enabled true -}}
      {{- .Values.postgresql.postgresqlPassword -}}
  {{- else -}}
      {{- .Values.externalPostgresql.password -}}
  {{- end -}}
{{- end -}}

# {{- define "app.postgresql.clairRawPassword" -}}
#   {{- if eq .Values.postgresql.enabled true -}}
#     {{- .Values.postgresql.postgresqlPassword -}}
#   {{- else -}}
#     {{- if .Values.externalPostgresql.clairPassword -}}
#         {{- .Values.externalPostgresql.clairPassword -}}
#     {{- else -}}
#         {{- .Values.externalPostgresql.password -}}
#     {{- end -}}
#   {{- end -}}
# {{- end -}}


# {{- define "app.postgresql.escapedClairRawPassword" -}}
#   {{- include "app.postgresql.clairRawPassword" . | urlquery | replace "+" "%20" -}}
# {{- end -}}

{{- define "app.postgresql.encryptedPassword" -}}
  {{- include "app.postgresql.rawPassword" . | b64enc | quote -}}
{{- end -}}

# {{- define "app.postgresql.encryptedClairPassword" -}}
#   {{- include "app.postgresql.clairRawPassword" . | b64enc | quote -}}
# {{- end -}}

{{- define "app.postgresql.coreDatabase" -}}
  {{- if eq .Values.postgresql.enabled true -}}
    {{- printf "%s" "registry" -}}
  {{- else -}}
    {{- .Values.externalPostgresql.coreDatabase -}}
  {{- end -}}
{{- end -}}

# {{- define "app.postgresql.clairDatabase" -}}
#   {{- if eq .Values.postgresql.enabled true -}}
#     {{- printf "%s" "postgres" -}}
#   {{- else -}}
#     {{- .Values.externalPostgresql.clairDatabase -}}
#   {{- end -}}
# {{- end -}}

{{- define "app.postgresql.sslmode" -}}
  {{- if eq .Values.postgresql.enabled true -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.externalPostgresql.sslmode -}}
  {{- end -}}
{{- end -}}

# {{- define "app.postgresql.clair" -}}
# postgres://{{ template "app.postgresql.clairUsername" . }}:{{ template "app.postgresql.escapedClairRawPassword" . }}@{{ template "app.postgresql.host" . }}:{{ template "app.postgresql.port" . }}/{{ template "app.postgresql.clairDatabase" . }}?sslmode={{ template "app.postgresql.sslmode" . }}
# {{- end -}}
