{{- define "app.neo4j.enabled" -}}
{{- if .Values.neo4j.asSubchart -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{- define "app.neo4j.name" -}}
  {{- printf "%s-%s" (include "common.names.fullname" .) (default "neo4j" .Values.neo4j.nameOverride) -}}
{{- end -}}

{{- define "app.neo4j.host" -}}
{{- if .Values.neo4j.asSubchart -}}
  {{ printf "%s.%s.svc.%s" (include "app.neo4j.name" .) .Release.Namespace .Values.clusterDomain }}
{{- else -}}
  {{ .Values.neo4j.hosts | first }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for web
*/}}
{{- define "app.neo4j.serviceAccountName" -}}
{{- if .Values.neo4j.serviceAccount }}
{{- default .Values.neo4j.serviceAccount.name (include "common.names.fullname" .) }}
{{- else }}
{{- include "common.names.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get the web configuration ConfigMap name.
*/}}
{{- define "app.neo4j.configMapName" -}}
{{- if .Values.neo4j.existingConfigMapName -}}
{{- printf "%s" (tpl .Values.neo4j.existingConfigMapName $) -}}
{{- else -}}
{{- printf "%s-config" (include "app.neo4j.name" .) -}}
{{- end -}}
{{- end -}}

############# secrets

{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "app.neo4j.useExistingSecret" -}}
{{- if .Values.neo4j.auth.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "app.neo4j.createSecret" -}}
{{- if not (include "app.neo4j.useExistingSecret" .) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the app neo4j secret name
*/}}
{{- define "app.neo4j.secretName" -}}
{{- if .Values.neo4j.auth.existingSecret }}
    {{- printf "%s" (tpl .Values.neo4j.auth.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "app.neo4j.name" .) -}}
{{- end -}}
{{- end -}}

{{/*
If no password is set in `Values.neo4j.password` generates a new random password and modifies Values.neo4j so that the same password is available everywhere
*/}}
{{- define "app.neo4j.password" -}}
  {{- if not .Values.neo4j.auth.password }}
    {{- $password :=  randAlphaNum 14 }}
    {{- $secretName := include "app.neo4j.secretName" . }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}

    {{- if $secret }}
      {{- $password = index $secret.data "NEO4J_AUTH" | b64dec | trimPrefix "neo4j/" -}}
    {{- end -}}
    {{- $ignored := set .Values.neo4j.auth "password" $password }}
  {{- end -}}
  {{- .Values.neo4j.auth.password }}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "app.neo4j.createTlsSecret" -}}
{{- if and .Values.neo4j.tls.enabled (not .Values.neo4j.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing app.neo4j TLS certificates
*/}}
{{- define "app.neo4j.tlsSecretName" -}}
{{- $secretName := .Values.neo4j.tls.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-tls-crt" (include "app.neo4j.name" .) -}}
{{- end -}}
{{- end -}}

############# volumes
{{- define "app.neo4j.volumeClaimTemplateSpec"  -}}
{{/*
This template converts a neo4j volume definition into a VolumeClaimTemplate spec based on the specified mode

The desired behaviour is specified by the 'mode' setting. Only the information in the selected 'mode' is used.

All modes except for "volume" are transformed into a "dynamic" spec and then into a plain VolumeClaimTemplate which is then output.
This is to ensure that there aren't dramatically different code paths (all routes ultimately use the same output path)

If "volume" mode is selected nothing is returned.
*/}}
{{- $ignored := required "Values must be passed in to helm volumeTemplate for use with internal templates" .Values -}}
{{- $ignored = required "Template must be passed in to helm volumeTemplate so that tpl function works" .Template -}}
{{- $name := required "name must be passed in to helm volumeTemplate so that tpl function works" .name -}}
{{/*
Deep Copy the provided volume object so that we can mutate it safely in this template
*/}}
{{- $volume := deepCopy .volume -}}

{{- $validModes := "share|selector|defaultStorageClass|dynamic|volume|volumeClaimTemplate" -}}
{{- if not ( $volume.mode | regexMatch $validModes ) -}}
  {{- fail ( cat "\nUnknown volume mode:" $volume.mode "\nValid modes are: " $validModes ) -}}
{{- end -}}
{{- $originalMode := $volume.mode -}}
{{- $ignored = get $volume $volume.mode | required (cat "Volume" $name "is missing field:" $volume.mode ) -}}
{{/*
If defaultStorageClass is chosen overwrite "dynamic" and switch to dynamic mode
*/}}
{{-  if eq $volume.mode "defaultStorageClass"  -}}
  {{- $ignored = set $volume "dynamic" $volume.defaultStorageClass -}}
  {{-  if $volume.dynamic.storageClassName -}}
    {{- fail "If using mode defaultStorageClass then storageClassName should not be set" -}}
  {{- end -}}
  {{- $ignored = set $volume "mode" "dynamic" -}}
{{- end -}}

{{/*
If selector is chosen process the selector template and then overwrite "dynamic" and switch to dynamic mode
*/}}
{{- if eq $volume.mode "selector" -}}
  {{- $ignored = set $volume.selector "selector" ( tpl ( toYaml $volume.selector.selectorTemplate ) . | fromYaml ) -}}
  {{- $ignored = set $volume "dynamic" $volume.selector -}}
  {{- $ignored = set $volume "mode" "dynamic" -}}
{{- end -}}

{{- if eq $volume.mode "dynamic" -}}
    {{- $requests := required ( include "app.neo4j.volumeClaimTemplate.resourceMissingError" (dict "name" $name "mode" $originalMode) ) $volume.dynamic.requests -}}
    {{- $ignored := required ( include "app.neo4j.volumeClaimTemplate.resourceMissingError" (dict "name" $name "mode" $originalMode) ) $requests.storage -}}

    {{- $ignored = set $volume "mode" "volumeClaimTemplate" -}}
    {{- $ignored = dict "requests" $requests | set $volume.dynamic "resources" -}}
    {{- $ignored = set $volume "volumeClaimTemplate" ( omit $volume.dynamic "requests" "selectorTemplate" ) -}}
{{- end -}}

{{- if eq $volume.mode "volumeClaimTemplate" -}}
    {{- omit $volume.volumeClaimTemplate "setOwnerAndGroupWritableFilePermissions" | toYaml  -}}
{{- end -}}
{{- end -}}

{{- define "app.neo4j.volumeSpec" -}}
{{- $ignored := required "Values must be passed in to helm volumeTemplate for use with internal templates" .Values -}}
{{- $ignored = required "Template must be passed in to helm volumeTemplate so that tpl function works" .Template -}}
{{- if eq .volume.mode "volume" -}}
{{ omit .volume.volume "setOwnerAndGroupWritableFilePermissions" | toYaml  }}
{{- end -}}
{{- end -}}


{{- define "app.neo4j.volumeClaimTemplate.resourceMissingError" -}}
"The storage capacity of volumes.{{ .name }} must be specified when using '{{ .mode }}' mode. Set volumes.{{ .name }}.{{ .mode }}.requests.storage to a suitable value (e.g. 100Gi)"
{{- end }}

{{- define "app.neo4j.volumeClaimTemplates" -}}
{{- $neo4jName := include "app.neo4j.name" . }}
{{- $template := .Template -}}
{{- range $name, $spec := .Values.neo4j.volumes -}}
{{- if $spec -}}
{{- $volumeClaim := dict "Template" $template "Values" $.Values.neo4j "volume" $spec "name" $name | include "app.neo4j.volumeClaimTemplateSpec" -}}
{{- if $volumeClaim -}}
- metadata:
    name: "{{ $name }}"
  spec: {{- $volumeClaim | nindent 4 }}
{{/* blank line, important! */}}{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* This template doesn't output anything unless the mode is "volume" */}}
{{- define "app.neo4j.volumes" -}}
{{- $template := .Template -}}
{{- range $name, $spec := .Values.neo4j.volumes -}}
{{- if $spec -}}
{{- $volumeYaml := dict "Template" $template "Values" $.Values.neo4j "volume" $spec | include "app.neo4j.volumeSpec" -}}
{{- if $volumeYaml -}}
- name: "{{ $name }}"
  {{- $volumeYaml | nindent 2 }}
{{/* blank line, important! */}}{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "app.neo4j.initChmodContainer" }}
{{- $initChmodScript := include "app.neo4j.initChmodScript" . }}
{{- if $initChmodScript }}
name: "set-volume-permissions"
image: {{ template "app.neo4j.image" . }}
env:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
securityContext:
  runAsNonRoot: false
  runAsUser: 0
  runAsGroup: 0
volumeMounts: {{- include "app.neo4j.volumeMounts" .Values.neo4j.volumes | nindent 2 }}
command:
  - "bash"
  - "-c"
  - |
    set -o pipefail -o errtrace -o errexit -o nounset
    shopt -s inherit_errexit
    [[ -n "${TRACE:-}" ]] && set -o xtrace
    {{- $initChmodScript | nindent 4 }}
{{- end }}
{{- end }}

{{- define "app.neo4j.initChmodScript" -}}
{{- $securityContext := .Values.neo4j.securityContext -}}
{{- range $name, $spec := .Values.neo4j.volumes -}}
{{- if (index $spec $spec.mode).setOwnerAndGroupWritableFilePermissions -}}
{{- if $securityContext -}}{{- if $securityContext.runAsUser }}

# change owner
chown -R "{{ $securityContext.runAsUser }}" "/{{ $name }}"
{{- end -}}{{- end -}}
{{- if $securityContext -}}{{- if $securityContext.runAsGroup }}

# change group
chgrp -R "{{ $securityContext.runAsGroup }}" "/{{ $name }}"
{{- end -}}{{- end }}

# make group writable
chmod -R g+rwx "/{{ $name }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "app.neo4j.volumeMounts" -}}
{{- range $name, $spec := . }}
- mountPath: "/{{ $name }}"
  name: "{{ if eq $spec.mode "share" }}{{ $spec.share.name }}{{ if eq $name "data" }}{{ fail "data volume does not support mode: 'share'"}}{{ end }}{{ else }}{{ $name }}{{ end }}"
  subPathExpr: "{{ if $spec.subPathExpr }}{{ $spec.subPathExpr }}{{ else }}{{ $name }}{{ if regexMatch "logs|metrics" $name }}/$(POD_NAME){{ end }}{{ end }}"
{{- end -}}
{{- end -}}

##### SSL 
