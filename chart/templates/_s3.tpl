# create: ingress URI for console, s3 credentials for root user and gamechanger role(s), bucket name/uri

{{/*
Create a default fully qualified minio name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "app.minio.fullname" -}}
{{- $name := default "minio" .Values.minio.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# .Values.minio.{rootUser, rootPassword}

# .Values.minio.existingSecret (rootUser, rootPassword)
{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "app.minio.useExistingSecret" -}}
{{- if .Values.minio.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}
{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "app.minio.createSecret" -}}
{{- if not (include "app.minio.useExistingSecret" .) -}}
    {{- true -}}
{{- end -}}
{{- end -}}
{{/*
Get the app ml secret name
*/}}
{{- define "app.minio.secretName" -}}
{{- if .Values.minio.existingSecret }}
    {{- printf "%s" (tpl .Values.minio.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "app.minio.fullname" .) -}}
{{- end -}}
{{- end -}}
# .Values.minio.tls

# .Values.minio.trustedCertsSecret

# .Values.minio.persistence

# .Values.minio.ingress

# .Values.minio.policies[]

# .Values.minio.users[]

# .Values.minio.customCommands[]

# .Values.minio.buckets[]

# .Values.minio.environment[]

