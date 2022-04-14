# GAMECHANGER chart



<!-- https://helm.sh/docs/topics/chart_repository/ -->
# Components
- common
- crawlers
- ml
- neo4j
- pipelines
- web
- Third party/external components
  - elasticsearch/AWS Opensearch
  - kibana/(not applicable)
  - postgres/AWS RDS Postgres
  - redis/AWS Elasticache
  - minio/AWS S3

# Deploying GAMECHANGER
In recognition of the various applicable use-cases, we've designed this chart to allow for integration with external service providers while also accomodating deployments into greenfield Kubernetes environments. The default `values.yaml` settings assume a greenfield deployment, and will deploy and configure all dependencies on the target cluster.

To disable these third party components and configure external services, ensure `external{component-name}.*` settings are set to appropriate values while `{component-name}.enabled` is set to `false`. 

## Minio/s3 settings
- root user creds
- bucket(s)
- bucket(s) policies
- user(s)
- user(s) policies
post install: 
create group, attach policy, create user, add to group

# GAMECHANGER `common` components 

# GAMECHANGER `crawler` components 

# GAMECHANGER `ml` components 

# Templating Guide
Below are recommended approaches to templating kubernetes resources within this chart. We draw inspiration from Bitnami's excellent Helm charts, adapting and customizing functions to fit this project's unique needs. 
## Secrets
Our priority when templating secret resources, including certificates, passwords, and other sensitive configuration material, should be to minimize the opportunity for exposing this data in plaintext. We'll also want to be flexible, as managing secrets should not be a burden for maintainers of this Helm Chart. Below we lay out recommended approaches for injecting secrets into k8s resources in this Helm Chart.

### Setting up `values.yaml` 
From a deployment perspective, use of secrets should occur in one of the following manners, ordered from most to least desireable:
1. referenced using a pre-populated K8s Secret resource, by name
2. K8s secret created upon deployment using a random generator
3. Provided as a plaintext value 

### `secrets.yaml` file and k8s opaque secrets  
To minimize complexity, each chart subcomponent should have a single `secrets.yaml` file where all subcomponent secrets will be templated. 

Additional notes:
- Related secrets may be stored as keys of a single secret object unless, collectively, these secrets may grow to larger than 1.5MB (max size for etcd resources). 
- Multiple secrets may be stored in the same `secrets.yaml` file by using the YAML [document separator](https://yaml.org/spec/1.0/#id2489959) `---`. 

### `_secrets.tpl` file and helper functions
Each secret object should have a corresponding template function in `_secrets.tpl`.


### Full example - Postgresql secret
Note the following features:
- we define conditional functions, referenced in the `secrets.yaml` file, to help determine how k8s should template based on input provided in `values.yaml`
  - generation of random secret material happens in `common.getValueFromSecret` if an existing Secret  name is not specified in `values.yaml`

```go
// in _secrets.tpl
{{/*
Return true if we should use an existingSecret. // if true, option 1 
*/}}
{{- define "postgresql.useExistingSecret" -}}
{{- if or .Values.global.postgresql.existingSecret .Values.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created // if true, option 2 or 3
*/}}
{{- define "postgresql.createSecret" -}}
{{- if not (include "postgresql.useExistingSecret" .) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL postgres user password 
*/}}
{{- define "postgresql.postgres.password" -}}
{{- if .Values.global.postgresql.postgresqlPostgresPassword }}  // option 3, global values
    {{- .Values.global.postgresql.postgresqlPostgresPassword -}}
{{- else if .Values.postgresqlPostgresPassword -}} // option 3, subchart values
    {{- .Values.postgresqlPostgresPassword -}}
{{- else -}}
    {{- include "common.getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "postgresql-postgres-password")  -}} // options 1 or 2
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL password 
*/}}
{{- define "postgresql.password" -}} // option 3, global values
{{- if .Values.global.postgresql.postgresqlPassword }}
    {{- .Values.global.postgresql.postgresqlPassword -}}
{{- else if .Values.postgresqlPassword -}} // option 3, subchart values
    {{- .Values.postgresqlPassword -}}
{{- else -}} // option 1 or 2, referenced from k8s secret 
    {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "postgresql-password")  -}}
{{- end -}}
{{- end -}}
{{/*
Return PostgreSQL username
*/}}
{{- define "postgresql.username" -}}
{{- if .Values.global.postgresql.postgresqlUsername }}
    {{- .Values.global.postgresql.postgresqlUsername -}}
{{- else -}}
    {{- .Values.postgresqlUsername -}}
{{- end -}}
{{- end -}}


```

```yaml
# in secrets.yaml
{{- if (include "postgresql.createSecret" .) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "common.names.fullname" . }}
  labels:
  {{- include "common.labels.standard" . | nindent 4 }}
  {{- if .Values.commonLabels }}
  {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- end }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
  namespace: {{ .Release.Namespace }}
type: Opaque
data:
  {{- if not (eq (include "postgresql.username" .) "postgres")  }}
  postgresql-postgres-password: {{ include "postgresql.postgres.password" . | b64enc | quote }}
  {{- end }}
  postgresql-password: {{ include "postgresql.password" . | b64enc | quote }}
  {{- if .Values.replication.enabled }}
  postgresql-replication-password: {{ include "postgresql.replication.password" . | b64enc | quote }}
  {{- end }}
  {{- if (and .Values.ldap.enabled .Values.ldap.bind_password) }}
  postgresql-ldap-password: {{ .Values.ldap.bind_password | b64enc | quote }}
  {{- end }}
{{- end -}}
---

```


