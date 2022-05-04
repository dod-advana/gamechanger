{{- define "app.crawlers.LOCAL_DOWNLOAD_DIRECTORY_PATH" }}
{{- if .current.LOCAL_DOWNLOAD_DIRECTORY_PATH }}
  {{- .current.LOCAL_DOWNLOAD_DIRECTORY_PATH }}
{{- else -}}
  {{- .default.LOCAL_DOWNLOAD_DIRECTORY_PATH | default "/var/tmp/dl" }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.restartPolicy" }}
{{- if .current.restartPolicy }}
  {{- .current.restartPolicy }}
{{- else -}}
  {{- .default.restartPolicy }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.PYTHON_CMD" }}
{{- if .current.PYTHON_CMD }}
  {{- .current.PYTHON_CMD }}
{{- else -}}
  {{- .default.PYTHON_CMD | default "/usr/bin/python3" }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.LOCAL_PREVIOUS_MANIFEST_LOCATION" }}
{{- if .current.LOCAL_PREVIOUS_MANIFEST_LOCATION }}
  {{- .current.LOCAL_PREVIOUS_MANIFEST_LOCATION }}
{{- else -}}
  {{- .default.LOCAL_PREVIOUS_MANIFEST_LOCATION }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.TEST_RUN" }}
{{- if .current.TEST_RUN }}
  {{- .current.TEST_RUN }}
{{- else -}}
  {{- .default.TEST_RUN }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.SEND_NOTIFICATIONS" }}
{{- if .current.SEND_NOTIFICATIONS }}
  {{- .current.SEND_NOTIFICATIONS }}
{{- else -}}
  {{- .default.SEND_NOTIFICATIONS }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.SLACK_HOOK_CHANNEL" }}
{{- if .current.SLACK_HOOK_CHANNEL }}
  {{- .current.SLACK_HOOK_CHANNEL }}
{{- else -}}
  {{- .default.SLACK_HOOK_CHANNEL }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.UPLOAD_LOGS" }}
{{- if .current.UPLOAD_LOGS }}
  {{- .current.UPLOAD_LOGS }}
{{- else -}}
  {{- .default.UPLOAD_LOGS }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.S3_BASE_LOG_PATH_URL" }}
{{- if .current.S3_BASE_LOG_PATH_URL }}
  {{- .current.S3_BASE_LOG_PATH_URL }}
{{- else -}}
  {{- .default.S3_BASE_LOG_PATH_URL }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.AWS_DEFAULT_REGION" }}
{{- if .current.AWS_DEFAULT_REGION }}
  {{- .current.AWS_DEFAULT_REGION }}
{{- else -}}
  {{- .default.AWS_DEFAULT_REGION }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.ENDPOINT_URL" }}
{{- if .current.ENDPOINT_URL }}
  {{- .current.ENDPOINT_URL }}
{{- else -}}
  {{- .default.ENDPOINT_URL }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.CRAWLER_OUTPUT_LOCATION" }}
{{- if .current.CRAWLER_OUTPUT_LOCATION }}
  {{- .current.CRAWLER_OUTPUT_LOCATION }}
{{- else -}}
  {{- .default.CRAWLER_OUTPUT_LOCATION }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.DELETE_AFTER_UPLOAD" }}
{{- if .current.DELETE_AFTER_UPLOAD }}
  {{- .current.DELETE_AFTER_UPLOAD }}
{{- else -}}
  {{- .default.DELETE_AFTER_UPLOAD }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.S3_UPLOAD_BASE_PATH" }}
{{- if .current.S3_UPLOAD_BASE_PATH }}
  {{- .current.S3_UPLOAD_BASE_PATH }}
{{- else -}}
  {{- .default.S3_UPLOAD_BASE_PATH }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.SKIP_S3_UPLOAD" }}
{{- if .current.SKIP_S3_UPLOAD }}
  {{- .current.SKIP_S3_UPLOAD }}
{{- else -}}
  {{- .default.SKIP_S3_UPLOAD }}
{{- end -}}
{{- end }}

{{- define "app.crawlers.BUCKET" }}
{{- if .current.BUCKET }}
  {{- .current.BUCKET }}
{{- else -}}
  {{- .default.BUCKET }}
{{- end -}}
{{- end }}


{{- define "app.crawlers.downloadDirectoryVolumeConfig.name" }}
{{- if .current.downloadDirectoryVolumeConfig }}
    {{- include .current.downloadDirectoryVolumeConfig.name -}}
{{- else -}}
    {{- .default.downloadDirectoryVolumeConfig.name -}}
{{- end -}}
{{- end -}}

{{- define "app.crawlers.downloadDirectoryVolumeConfig.claimName" }}
{{- if .current.downloadDirectoryVolumeConfig }}
    {{- include .current.downloadDirectoryVolumeConfig.claimName -}}
{{- else -}}
    {{- .default.downloadDirectoryVolumeConfig.claimName -}}
{{- end -}}
{{- end -}}

{{- define "app.crawlers.downloadDirectoryVolumeConfig.mountPath" }}
{{- if .current.downloadDirectoryVolumeConfig }}
    {{- include .current.downloadDirectoryVolumeConfig.mountPath -}}
{{- else -}}
    {{- .default.downloadDirectoryVolumeConfig.mountPath -}}
{{- end -}}
{{- end -}}