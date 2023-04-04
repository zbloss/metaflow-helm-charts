{{/*
Kubegres
*/}}
{{- define "kubegres.name" -}}
{{- default .Chart.Name .Values.kubegres.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "default.databaseName" -}}
{{- default "postgres" .Values.global.database.defaultDatabaseName }}
{{- end }}

{{- define "default.databaseUser" -}}
{{- default "postgres" .Values.global.database.defaultDatabaseUser }}
{{- end }}

{{- define "kubegres.host" -}}
{{- printf "%s.%s.svc.cluster.local" (include "kubegres.name" .) .Release.Namespace }}
{{- end }}

{{- define "kubegres.dbEnvVars" -}}
- name: POSTGRES_PASSWORD
{{- if .Values.global.secrets.superUserPassword }}
  value: {{ .Values.global.secrets.superUserPassword | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.secrets.secretName | quote }}
      key: {{ default "superUserPassword" .Values.global.secrets.customSuperUserSecretKey }}
{{- end }}
- name: POSTGRES_REPLICATION_PASSWORD
{{- if .Values.global.secrets.replicationUserPassword }}
  value: {{ .Values.global.secrets.replicationUserPassword | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.secrets.secretName | quote }}
      key: {{ default "replicationUserPassword" .Values.global.secrets.customReplicationUserSecretKey }}
{{- end }}
- name: POSTGRES_DB
  value: {{ include "default.databaseName" . }}
- name: POSTGRES_USER
  value: {{ include "default.databaseUser" . }}
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "metaflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metaflow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "metaflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metaflow.labels" -}}
helm.sh/chart: {{ include "metaflow.chart" . }}
{{ include "metaflow.selectorLabels" . }}
{{- end }}


{{/*
Common Annotations
*/}}

{{- define "metaflow.annotations" -}}
helm.sh/chart: {{ include "metaflow.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Release.Service }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- if .Release.Revision }}
app.kubernetes.io/revision: {{ .Release.Revision | quote }}
{{- end }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "metaflow.selectorLabels" -}}
app.kubernetes.io/name: "name"
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "metaflow-service.serviceAccountName" -}}
{{- if .Values.metaflowService.serviceAccount.create }}
{{- default (include "metaflow.fullname" .) .Values.metaflowService.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "metaflow-service.metadatadbEnvVars" -}}
- name: MF_METADATA_DB_NAME
  value: {{ include "default.databaseName" . }}
- name: MF_METADATA_DB_PORT
  value: {{ default "5432" .Values.metaflowService.metadatadb.port | quote }}
- name: MF_METADATA_DB_PSWD
{{- if .Values.global.secrets.superUserPassword }}
  value: {{ .Values.global.secrets.superUserPassword | quote}}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.secrets.secretName }}
      key: {{ default "superUserPassword" .Values.global.secrets.customSuperUserSecretKey }}
{{- end }}
- name: MF_METADATA_DB_USER
  value: {{ include "default.databaseUser" . }}
- name: MF_METADATA_DB_HOST
  value: {{ default (include "kubegres.host" .) .Values.metaflowService.metadatadb.host}}
{{- if .Values.metaflowService.metadatadb.schema }}
- name: DB_SCHEMA_NAME
  value: {{ .Values.metaflowService.metadatadb.schema | quote }}
{{- end }}
{{- end }}

{{- define "metaflow-service.fullImage" -}}
{{- $imageTag := default .Chart.AppVersion .Values.metaflowService.image.tag }}
{{- $imageRepository := default "netflixoss/metaflow_metadata_service" .Values.metaflowService.image.repository }}
{{- printf "%s:%s" $imageRepository $imageTag }}
{{- end }}