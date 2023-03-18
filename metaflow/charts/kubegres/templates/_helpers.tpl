{{/*
Expand the name of the chart.
*/}}
{{- define "kubegres.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kubegres.fullname" -}}
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
{{- define "kubegres.chart" -}}
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
{{- define "kubegres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubegres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kubegres.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kubegres.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
