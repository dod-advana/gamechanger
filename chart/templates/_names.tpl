{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" | lower -}}
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
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" | lower -}}
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

# gc-global-component names
{{/*
Create the name of the service account to use for all app components
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount }}
{{- default .Values.serviceAccount.name (include "common.names.fullname" .) }}
{{- else }}
{{- include "common.names.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get the global configuration ConfigMap name.
*/}}
{{- define "app.configMapName" -}}
{{- if .Values.configMapName -}}
{{- printf "%s" (tpl .Values.configMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "common.names.chart" .) -}}
{{- end -}}
{{- end -}}

# gc-ml-component names
{{- define "app.ml.name" -}}
  {{- printf "%s-ml" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "app.ml.fqdn" -}}
{{ $name := default (include "app.ml.name" . | lower ) .Values.ingress.ml.hostname }}
{{- if .Values.externalDomain -}}
{{- printf "%s.%s" $name .Values.externalDomain -}}
{{- else -}}
{{ printf "%s" $name }}
{{- end -}}
{{- end -}}

{{- define "app.ml.host" -}}
  {{ printf "%s.%s.svc.%s" (include "app.ml.name" .) .Release.Namespace .Values.clusterDomain }}
{{- end -}}

{{/*
Get the ml configuration ConfigMap name.
*/}}
{{- define "app.ml.configMapName" -}}
{{- if .Values.ml.existingConfigMapName -}}
{{- printf "%s" (tpl .Values.ml.existingConfigMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "app.ml.name" .) -}}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use for ml
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
  {{- printf "%s-ml.%s.%s" (include "common.names.fullname" .) "one-time-job" (now | date "20060102-150405") }}
{{- end }}

# gc-web-component names
{{- define "app.web.name" -}}
  {{- printf "%s-web" (include "common.names.fullname" .) -}}
{{- end -}}

{{- define "app.web.fqdn" -}}
{{ $name := default (include "app.web.name" . | lower ) .Values.ingress.web.hostname }}
{{- if .Values.externalDomain -}}
{{- printf "%s.%s" $name .Values.externalDomain -}}
{{- else -}}
{{ printf "%s" $name }}
{{- end -}}
{{- end -}}

{{/*
Create the external web url, with protocol, for external hosts/clients
*/}}
{{- define "app.web.externalUrl" -}}
{{- if .Values.web.tls.enabled -}}
  {{- printf "https://%s" (include "app.web.fqdn" . ) -}}
{{- else -}}
  {{- printf "http://%s" (include "app.web.fqdn" . ) -}}
{{- end -}}
{{- end -}}

{{/*
One Time Job Name
*/}}
{{- define "app.web.initJobName" }}
  {{- printf "%s-web.%s.%s" (include "common.names.fullname" .) "one-time-job" (now | date "20060102-150405") }}
{{- end }}

{{/*
Create the name of the service account to use for web
*/}}
{{- define "app.web.serviceAccountName" -}}
{{- if .Values.web.serviceAccount }}
{{- default .Values.web.serviceAccount.name (include "common.names.fullname" .) }}
{{- else }}
{{- include "common.names.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get the web configuration ConfigMap name.
*/}}
{{- define "app.web.configMapName" -}}
{{- if .Values.web.existingConfigMapName -}}
{{- printf "%s" (tpl .Values.web.existingConfigMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "app.web.name" .) -}}
{{- end -}}
{{- end -}}


# gc-crawlers-component names
{{- define "app.crawlers.name" -}}
  {{- printf "%s-crawlers" (include "common.names.fullname" .) -}}
{{- end -}}

# gc-pipelines-component names
{{- define "app.pipelines.name" -}}
  {{- printf "%s-pipelines" (include "common.names.fullname" .) -}}
{{- end -}}

