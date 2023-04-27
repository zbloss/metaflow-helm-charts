{{/*
Kubegres
*/}}
{{- define "kubegres.name" -}}
{{- default .Chart.Name .Values.global.database.kubegresName | trunc 63 | trimSuffix "-" }}
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

{{- define "kubegres.pvName" -}}
{{ default (printf "%s-%s" .Release.Name "kubegres-pv") .Values.global.database.backup.pvName }}
{{- end }}


{{- define "kubegres.pvcName" -}}
{{ default (printf "%s-%s" .Release.Name "kubegres-pvc") .Values.global.database.backup.pvcName }}
{{- end }}

{{/*
Metaflow Global
*/}}

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
app.kubernetes.io/name: {{ default .Chart.Name .Values.fullnameOverride}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Metaflow-Service
*/}}

{{- define "metaflow-service.name" -}}
{{- $defaultName := (printf "%s-%s" (include "metaflow.name" .) "service") }}
{{- default $defaultName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "metaflow-service.serviceName" -}}
{{- $defaultName := (printf "%s-%s" (include "metaflow-service.name" .) "svc") }}
{{- default $defaultName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "metaflow-service.selectorLabels" -}}
{{ include "metaflow.selectorLabels" . }}
metaflow-package: "metaflow-service"
{{- end }}

{{- define "metaflow-service.hostAndPort" -}}
{{- printf "http://%s.%s.svc.cluster.local:%s" (include "metaflow-service.serviceName" .) .Release.Namespace (toString .Values.metaflowService.service.port) }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metaflow-service.serviceAccountName" -}}
{{- if .Values.metaflowService.serviceAccount.create }}
{{- $metaflowServiceName := default (include "metaflow-service.name" .) .Values.metaflowService.serviceAccount.name }}
{{- printf "%s-%s" $metaflowServiceName "sa" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default "default-sa" .Values.serviceAccount.name }}
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

{{- define "metaflow-service.initContainerCommands" -}}
- "/opt/latest/bin/python3"
- "/root/run_goose.py"
{{- if .Values.metaflowService.databaseMigrations.onlyIfDbEmpty }}
- "--only-if-empty-db"
{{- end }}
{{- end }}

{{- define "metaflow-service.containerCommands" -}}
{{ $defaultCommands := toYaml (list "/opt/latest/bin/python3" "-m" "services.metadata_service.server") }}
{{ $command := default $defaultCommands .Values.metaflowService.containerCommands }}
{{- toYaml $command | trim | nindent 10 -}}
{{- end }}

{{/*
Metaflow-UI
*/}}

{{- define "metaflow-ui.name" -}}
{{- $defaultName := (printf "%s-%s" (include "metaflow.name" .) "ui") }}
{{- default $defaultName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "metaflow-ui.selectorLabels" -}}
{{ include "metaflow.selectorLabels" . }}
metaflow-package: "metaflow-ui"
{{- end }}

{{- define "metaflow-ui.fullImage" -}}
{{- $imageTag := default .Chart.AppVersion .Values.metaflowUi.image.tag }}
{{- $imageRepository := default "zacharybloss/metaflow-ui" .Values.metaflowUi.image.repository }}
{{- printf "%s:%s" $imageRepository $imageTag }}
{{- end }}

{{- define "metaflow-ui.serviceName" -}}
{{- $defaultName := (printf "%s-%s" (include "metaflow-ui.name" .) "svc") }}
{{- default $defaultName .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
