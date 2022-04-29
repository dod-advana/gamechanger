{{/*
Generate secret name.
Usage:
{{ include "common.secrets.name" (dict "existingSecret" .Values.path.to.the.existingSecret "defaultNameSuffix" "mySuffix" "context" $) }}

Params:
  - existingSecret - ExistingSecret/String - Optional. The path to the existing secrets in the values.yaml given by the user
    to be used instead of the default one. Allows for it to be of type String (just the secret name) for backwards compatibility.
    +info: https://github.com/bitnami/charts/tree/master/bitnami/common#existingsecret
  - defaultNameSuffix - String - Optional. It is used only if we have several secrets in the same deployment.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "common.secrets.name" -}}
{{- $name := (include "common.names.fullname" .context) -}}

{{- if .defaultNameSuffix -}}
{{- $name = printf "%s-%s" $name .defaultNameSuffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- with .existingSecret -}}
{{- if not (typeIs "string" .) -}}
{{- with .name -}}
{{- $name = . -}}
{{- end -}}
{{- else -}}
{{- $name = . -}}
{{- end -}}
{{- end -}}

{{- printf "%s" $name -}}
{{- end -}}

{{/*
Generate secret key.
Usage:
{{ include "common.secrets.key" (dict "existingSecret" .Values.path.to.the.existingSecret "key" "keyName") }}

Params:
  - existingSecret - ExistingSecret/String - Optional. The path to the existing secrets in the values.yaml given by the user
    to be used instead of the default one. Allows for it to be of type String (just the secret name) for backwards compatibility.
    +info: https://github.com/bitnami/charts/tree/master/bitnami/common#existingsecret
  - key - String - Required. Name of the key in the secret.
*/}}
{{- define "common.secrets.key" -}}
{{- $key := .key -}}

{{- if .existingSecret -}}
  {{- if not (typeIs "string" .existingSecret) -}}
    {{- if .existingSecret.keyMapping -}}
      {{- $key = index .existingSecret.keyMapping $.key -}}
    {{- end -}}
  {{- end }}
{{- end -}}

{{- printf "%s" $key -}}
{{- end -}}

{{/*
Generate secret password or retrieve one if already created.
Usage:
{{ include "common.secrets.passwords.manage" (dict "secret" "secret-name" "key" "keyName" "providedValues" (list "path.to.password1" "path.to.password2") "length" 10 "strong" false "chartName" "chartName" "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - key - String - Required - Name of the key in the secret.
  - providedValues - List<String> - Required - The path to the validating value in the values.yaml, e.g: "mysql.password". Will pick first parameter with a defined value.
  - length - int - Optional - Length of the generated random password.
  - strong - Boolean - Optional - Whether to add symbols to the generated random password.
  - chartName - String - Optional - Name of the chart used when said chart is deployed as a subchart.
  - context - Context - Required - Parent context.
*/}}
{{- define "common.secrets.passwords.manage" -}}

{{- $password := "" }}
{{- $subchart := "" }}
{{- $chartName := default "" .chartName }}
{{- $passwordLength := default 10 .length }}
{{- $providedPasswordKey := include "common.utils.getKeyFromList" (dict "keys" .providedValues "context" $.context) }}
{{- $providedPasswordValue := include "common.utils.getValueFromKey" (dict "key" $providedPasswordKey "context" $.context) }}
{{- $secret := (lookup "v1" "Secret" $.context.Release.Namespace .secret) }}
{{- if $secret }}
  {{- if index $secret.data .key }}
  {{- $password = index $secret.data .key }}
  {{- end -}}
{{- else if $providedPasswordValue }}
  {{- $password = $providedPasswordValue | toString | b64enc | quote }}
{{- else }}

  {{- if .context.Values.enabled }}
    {{- $subchart = $chartName }}
  {{- end -}}

  {{- $requiredPassword := dict "valueKey" $providedPasswordKey "secret" .secret "field" .key "subchart" $subchart "context" $.context -}}
  {{- $requiredPasswordError := include "common.validations.values.single.empty" $requiredPassword -}}
  {{- $passwordValidationErrors := list $requiredPasswordError -}}
  {{- include "common.errors.upgrade.passwords.empty" (dict "validationErrors" $passwordValidationErrors "context" $.context) -}}
  
  {{- if .strong }}
    {{- $subStr := list (lower (randAlpha 1)) (randNumeric 1) (upper (randAlpha 1)) | join "_" }}
    {{- $password = randAscii $passwordLength }}
    {{- $password = regexReplaceAllLiteral "\\W" $password "@" | substr 5 $passwordLength }}
    {{- $password = printf "%s%s" $subStr $password | toString | shuffle | b64enc | quote }}
  {{- else }}
    {{- $password = randAlphaNum $passwordLength | b64enc | quote }}
  {{- end }}
{{- end -}}
{{- printf "%s" $password -}}
{{- end -}}

{{/*
Returns whether a previous generated secret already exists
Usage:
{{ include "common.secrets.exists" (dict "secret" "secret-name" "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - context - Context - Required - Parent context.
*/}}
{{- define "common.secrets.exists" -}}
{{- $secret := (lookup "v1" "Secret" $.context.Release.Namespace .secret) }}
{{- if $secret }}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "common.getValueFromSecret" }}
{{- $len := (default 16 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64dec -}}
{{- else -}}
{{- randAlphaNum $len -}}
{{- end -}}
{{- end }}

############ begin app component secrets


# gc-ml-components
{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "app.ml.useExistingSecret" -}}
{{- if .Values.ml.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the app ml secret name
*/}}
{{- define "app.ml.secretName" -}}
{{- if .Values.ml.existingSecret }}
    {{- printf "%s" (tpl .Values.ml.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "app.ml.name" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "app.ml.createSecret" -}}
{{- $secretName := include "app.ml.secretName" . }}
{{- $secret := include "common.secrets.exists" (dict "secret" $secretName "context" $) }}
{{- if and (not .Values.ml.existingSecret) (not $secret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing app.ml TLS certificates
*/}}
{{- define "app.ml.tlsSecretName" -}}
{{- $secretName := .Values.ml.tls.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-tls-crt" (include "app.ml.name" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "app.ml.createTlsSecret" -}}
{{- $secretName := include "app.ml.tlsSecretName" . }}
{{- $secret := include "common.secrets.exists" (dict "secret" $secretName "context" $) }}
{{- if and .Values.ml.tls.enabled (not .Values.ml.tls.existingSecret) (not $secret) }}
    {{- true -}}
{{- end -}}
{{- end -}}


# gc-web-components
{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "app.web.useExistingSecret" -}}
{{- if .Values.web.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "app.web.createSecret" -}}
{{- $secretName := include "app.web.secretName" . }}
{{- $secret := include "common.secrets.exists" (dict "secret" $secretName "context" $)  }}
{{- if and (not .Values.web.existingSecret) (not $secret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the app web secret name
*/}}
{{- define "app.web.secretName" -}}
{{- if .Values.web.existingSecret }}
    {{- printf "%s" (tpl .Values.web.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-env-secret" (include "app.web.name" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing app.ml TLS certificates
*/}}
{{- define "app.web.tlsSecretName" -}}
{{- $secretName := .Values.web.tls.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-tls-crt" (include "app.web.name" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "app.web.createTlsSecret" -}}
{{- $secretName := include "app.web.tlsSecretName" . }}
{{- $secret := include "common.secrets.exists" (dict "secret" $secretName "context" $)  }}
{{- if and .Values.web.tls.enabled (not .Values.web.tls.existingSecret) (not $secret) }}
    {{- true -}}
{{- end -}}
{{- end -}}


# gc-crawlers-components
{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "app.crawlers.useExistingSecret" -}}
{{- if .Values.crawlers.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "app.crawlers.createSecret" -}}
{{- $secretName := include "app.crawlers.secretName" . }}
{{- $secret := include "common.secrets.exists" (dict "secret" $secretName "context" $)  }}
{{- if and (not .Values.crawlers.existingSecret) (not $secret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the app ml secret name
*/}}
{{- define "app.crawlers.secretName" -}}
{{- if .Values.crawlers.existingSecret }}
    {{- printf "%s" (tpl .Values.crawlers.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret" (include "app.crawlers.name" .) -}}
{{- end -}}
{{- end -}}