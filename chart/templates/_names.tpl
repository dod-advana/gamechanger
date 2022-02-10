{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.names.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified dependency name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Usage:
{{ include "common.names.dependency.fullname" (dict "chartName" "dependency-chart-name" "chartValues" .Values.dependency-chart "context" $) }}
*/}}
{{- define "common.names.dependency.fullname" -}}
{{- if .chartValues.fullnameOverride -}}
{{- .chartValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .chartName .chartValues.nameOverride -}}
{{- if contains $name .context.Release.Name -}}
{{- .context.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

############ begin app component names
{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount }}
{{- default .Values.serviceAccount.name (include "common.names.fullname" .) }}
{{- else }}
{{- include "common.names.fullname" . }}
{{- end }}
{{- end }}

{{- define "app.crawlers" -}}
  {{- printf "%s-crawlers" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "app.ml" -}}
  {{- printf "%s-ml" (include "common.names.fullname" .) -}}
{{- end -}}
### app configmap templating
{{/*
Get the global configuration ConfigMap name.
*/}}
{{- define "app.configMapName" -}}
{{- if .Values.ml.configMapName -}}
{{- printf "%s" (tpl .Values.ml.configMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "common.names.chart" .) -}}
{{- end -}}
{{- end -}}


{{/*
Get the ml configuration ConfigMap name.
*/}}
{{- define "app.ml.configMapName" -}}
{{- if .Values.ml.existingConfigMapName -}}
{{- printf "%s" (tpl .Values.ml.existingConfigMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "app.ml" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the ml configuration ConfigMap name.
*/}}
{{- define "app.ml.httpsProxy.configMapName" -}}
{{- if .Values.ml.httpsProxy.existingConfigMap -}}
{{- printf "%s" (tpl .Values.ml.httpsProxy.existingConfigMap $) -}}
{{- else -}}
{{- printf "%s-https-config" (include "app.ml" .) -}}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "app.ml.serviceAccountName" -}}
{{- if .Values.ml.serviceAccount }}
{{- default .Values.ml.serviceAccount.name (include "common.names.fullname" .) }}
{{- else }}
{{- include "common.names.fullname" . }}
{{- end }}
{{- end }}
{{/*
One Time Job Name
*/}}
{{- define "app.ml.initJobName" }}
  {{- printf "%s.%s.%s" (include "common.names.fullname" .) "one-time-job" (now | date "20060102-150405") }}
{{- end }}

{{- define "app.neo4j" -}}
  {{- printf "%s-neo4j" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "app.pipelines" -}}
  {{- printf "%s-pipelines" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "app.portal" -}}
  {{- printf "%s-portal" (include "common.names.fullname" .) -}}
{{- end -}}


{{/*
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.redis.fullname" -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- printf "%s-%s-master" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}