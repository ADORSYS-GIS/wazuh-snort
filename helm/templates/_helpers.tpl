{{/*
Expand the name of the chart.
*/}}
{{- define "snort-ips.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "snort-ips.fullname" -}}
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
{{- define "snort-ips.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "snort-ips.labels" -}}
helm.sh/chart: {{ include "snort-ips.chart" . }}
{{ include "snort-ips.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "snort-ips.selectorLabels" -}}
app.kubernetes.io/name: {{ include "snort-ips.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "snort-ips.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "snort-ips.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Volume name. Choose externalPvcName if set, otherwise use the default PVC name
*/}}
{{- define "snort-ips.volumeName" -}}
{{- if .Values.externalPvcName }}
{{- .Values.externalPvcName }}
{{- else }}
{{- $fullName := (include "snort-ips.fullname" .) }}
{{- printf "%s-%s" $fullName "pvc" }}
{{- end }}
{{- end }}