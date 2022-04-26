{{/*
Return the proper image name
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use common.images.renderPullSecrets instead)
{{ include "common.images.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "common.images.pullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names evaluating values as templates
{{ include "common.images.renderPullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "context" $) }}
*/}}
{{- define "common.images.renderPullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $context := .context }}

  {{- if $context.Values.global }}
    {{- range $context.Values.global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets (include "common.tplvalues.render" (dict "value" . "context" $context)) -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets (include "common.tplvalues.render" (dict "value" . "context" $context)) -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

############ begin app image tpl
{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "app.ml.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.ml.image .Values.ml.init.container.image .Values.ml.init.job.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper app ml image name (based on .Values.x.image block)
*/}}
{{- define "app.ml.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.ml.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper init container image name 
*/}}
{{- define "app.ml.init.container.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.ml.init.container.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper init job image name 
*/}}
{{- define "app.ml.init.job.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.ml.init.job.image "global" .Values.global) }}
{{- end -}}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "app.web.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.web.image .Values.web.init.container.image .Values.web.init.job.image ) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper app ml image name (based on .Values.x.image block)
*/}}
{{- define "app.web.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.web.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper init container image name 
*/}}
{{- define "app.web.init.container.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.web.init.container.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper init job image name 
*/}}
{{- define "app.web.init.job.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.web.init.job.image "global" .Values.global) }}
{{- end -}}

#### neo4j images
{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "app.neo4j.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.neo4j.image) "global" .Values.global) }}
{{- end -}}
{{/*
Return the proper app ml image name (based on .Values.x.image block)
*/}}
{{- define "app.neo4j.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.neo4j.image "global" .Values.global) }}
{{- end -}}
####
{{/*
Return the proper default crawlers cronjob image name 
*/}}
{{- define "app.crawlers.default.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.crawlers.defaultCronJobImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper crawlers cronjob image name 
*/}}
{{- define "app.crawlers.image" -}}
{{- if .current.image }}
    {{- include "common.images.image" (dict "imageRoot" .current.image ) -}}
{{- else -}}
{{- printf "%s" .default -}}
{{- end -}}
{{- end -}}

