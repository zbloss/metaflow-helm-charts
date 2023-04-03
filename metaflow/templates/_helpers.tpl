{{/*
Expand the name of the chart.
*/}}
{{- define "metaflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Kubegres
*/}}
{{- define "kubegres.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kubegress.dbEnvVars" -}}
- name: POSTGRES_PASSWORD
{{- if .Values.kubegres.secrets.superUserPassword }}
  value: {{ .Values.kubegres.secrets.superUserPassword | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.kubegres.secrets.secretName | quote }}
      value: {{ default "superUserPassword" .Values.kubegres.secrets.customSuperUserSecretKey }}
{{- end }}
- name: POSTGRES_REPLICATION_PASSWORD
{{- if .Values.kubegres.secrets.replicationUserPassword }}
  value: {{ .Values.kubegres.secrets.replicationUserPassword | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.kubegres.secrets.secretName | quote }}
      value: {{ default "replicationUserPassword" .Values.kubegres.secrets.customReplicationUserSecretKey }}
{{- end }}
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
app.kubernetes.io/name: {{ include "metaflow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metaflow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metaflow.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
