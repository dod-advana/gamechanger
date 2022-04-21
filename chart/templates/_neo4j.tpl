
{{- define "app.neo4j.name" -}}
{{- if (index .Values "neo4j-standalone").asSubchart -}}
    {{ printf "%s" (include "neo4j.name" (index .Subcharts "neo4j-standalone")) }}
{{- else -}}
    {{ default "neo4j" (index .Values "neo4j-standalone").name }}
{{- end -}}
{{- end -}}

{{- define "app.neo4j.host" -}}
{{- if (index .Values "neo4j-standalone").asSubchart -}}
  {{ printf "%s.%s.svc.%s" (include "app.neo4j.name" .) .Release.Namespace .Values.clusterDomain }}
{{- else -}}
  {{- (index .Values "neo4j-standalone").host | first -}}
{{- end -}}
{{- end -}}