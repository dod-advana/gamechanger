{{/*
Create a default fully qualified elasticsearch name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.elasticsearch.fullname" -}}
{{- $name := default "elasticsearch" .Values.elasticsearch.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
# https://stackoverflow.com/questions/47791971/how-can-you-call-a-helm-helper-template-from-a-subchart-with-the-correct-conte
# https://github.com/bitnami/charts/blob/85c67c1f5dcca2864b2cd81758d0dd7d447d2360/bitnami/elasticsearch/templates/_helpers.tpl#L56
{{/*
Returns hostnames of either given or subchart es hosts
*/}}
{{- define "app.elasticsearch.hosts" -}}
{{- if .Values.elasticsearch.asSubchart -}}
    {{ (include "elasticsearch.hosts" .Subcharts.elasticsearch) | splitList "," }}
{{- else -}}
    {{ .Values.elasticsearch.hosts }}
{{- end -}}
{{- end -}}

{{/*
Returns first hostname of either given or subchart es hosts; since templates only return strings, need a completely different function to parse and return string
*/}}
{{- define "app.elasticsearch.host" -}}
{{- if .Values.elasticsearch.asSubchart -}}
    {{ (include "elasticsearch.hosts" .Subcharts.elasticsearch) | splitList "," | first }}
{{- else -}}
    {{ .Values.elasticsearch.hosts | first }}
{{- end -}}
{{- end -}}

{{- define "app.elasticsearch.port" -}}
{{- if .Values.elasticsearch.asSubchart -}}
    {{- .Values.elasticsearch.master.service.port -}}
{{- else -}}
    {{- .Values.elasticsearch.port -}}
{{- end -}}
{{- end -}}

# if auth is enabled, we either need username/password or cert-based auth for gc apps
{{- define "app.elasticsearch.authEnabled" -}}
{{- .Values.elasticsearch.security.enabled -}}
{{- end -}}

{{/*
Create a secret when we're not using a subchart, i.e. external es, and we don't provide an existing secret
*/}}
{{- define "app.elasticsearch.createSecret" -}}
{{- if and .Values.elasticsearch.security.enabled (not .Values.elasticsearch.security.existingSecret) (not .Values.elasticsearch.asSubchart) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Elasticsearch authentication credentials secret name
*/}}
{{- define "app.elasticsearch.secretName" -}}
{{- coalesce .Values.elasticsearch.security.existingSecret (include "app.elasticsearch.fullname" .) -}}
{{- end -}}


{{- define "app.elasticsearch.security.envVars" -}}
{{- if .Values.elasticsearch.asSubchart -}}
- name: GAMECHANGER_ELASTICSEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "elasticsearch.secretName" .Subcharts.elasticsearch }}
      key: elasticsearch-password
- name: ES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "elasticsearch.secretName" .Subcharts.elasticsearch }}
      key: elasticsearch-password

- name: GAMECHANGER_ELASTICSEARCH_CA
  valueFrom:
    secretKeyRef:
      name: {{ include "elasticsearch.master.tlsSecretName" .Subcharts.elasticsearch }}
      key: ca.crt

- name: EDA_ELASTICSEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "elasticsearch.secretName" .Subcharts.elasticsearch }}
      key: elasticsearch-password
# {{/*
- name: EDA_ELASTICSEARCH_CA
  valueFrom:
    secretKeyRef:
      name: {{ include "elasticsearch.master.tlsSecretName" .Subcharts.elasticsearch }}
      key: ca.crt
# */}}
{{- else -}}
- name: GAMECHANGER_ELASTICSEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "app.elasticsearch.secretName" . }}
      key: elasticsearch-password
- name: ES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "app.elasticsearch.secretName" . }}
      key: elasticsearch-password
- name: GAMECHANGER_ELASTICSEARCH_CA
  valueFrom:
    secretKeyRef:
      name: {{ include "app.elasticsearch.secretName" . }}
      key: {{ .Values.elasticsearch.security.tls.certCAFilename }}
- name: EDA_ELASTICSEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "app.elasticsearch.secretName" . }}
      key: elasticsearch-password
- name: EDA_ELASTICSEARCH_CA
  valueFrom:
    secretKeyRef:
      name: {{ include "app.elasticsearch.secretName" . }}
      key: {{ .Values.elasticsearch.security.tls.certCAFilename }}
{{- end -}}
{{- end -}}