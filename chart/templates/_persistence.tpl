{{/*
Persistent volume claim name
*/}}
{{- define "app.ml.pvcName" -}}
{{- default (printf "%s-vol" (include "app.ml.name" .)) .Values.ml.persistence.existingClaim -}}
{{- end }}