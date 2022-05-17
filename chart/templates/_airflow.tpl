{{/*
Create a default fully qualified airflow name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.airflow.fullname" -}}
{{- $name := default "airflow" .Values.airflow.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
