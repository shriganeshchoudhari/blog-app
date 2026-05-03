# G-Blog X: Deployment Guide

## 1. Overview
This document describes how to deploy G-Blog X in a Kubernetes environment using Helm, Jenkins, and ArgoCD, following GitOps principles.

## 2. Environment Map
- Local: dev environment for frontend/backend
- Staging: pre-prod with replicated infra
- Prod: production cluster and services

## 3. Prerequisites
- Kubernetes cluster (AWS EKS) with kubectl access
- Helm 3.x installed
- Terraform for infra provisioning (if applicable)
- Jenkins server and ArgoCD installed
- Vault and OPA configured in cluster
- OpenTelemetry collector configured (or external)

## 4. Deployment Flow
1. Push changes to Git repository (Helm chart changes or values files)
2. Jenkins builds image, updates helm values-prod.yaml, and commits
3. ArgoCD detects changes and performs Helm-based deployment to EKS
4. Rollout observed via ArgoCD UI; monitor via dashboards

## 5. Rollback & Rollout Strategy
- Use ArgoCD automated sync with prune and self-heal enabled
- Rollback to a previous revision via ArgoCD UI or CLI; monitor the rollback progress

## 6. Helm Chart Details & Environment Customization
- Values per environment: prod vs staging vs dev
- Example: enabling TLS, configuring ingress, enabling/disabling OTEL, and toggling Vault integration
- Secrets management via Vault: reference secrets through annotations and environment vars
- Health checks and probes for each service in templates

## 9. Canary Deployments (Phase 4)
- Prerequisites: Argo Rollouts CRD installed; ArgoCD configured to manage Rollouts in staging
- Rollout strategy: canary with progressive weight (e.g., 10% -> 50% -> 100%)
- Rollout manifest will be defined in Helm templates (e.g., helm/gblog/templates/rollout.yaml)
- Observability: ensure canary rollout health checks; dashboards show canary slice metrics
- Rollback: if canary fails, rollback to previous stable revision via ArgoCD
- Activation: push Helm values; ArgoCD will apply and roll canaries accordingly

## 7. Observability & Alerts in Deployment
- Helm charts include Prometheus annotations for metrics endpoints
- Jaeger/OTLP tracing enabled per env; dashboards wired in Grafana

## 8. Security & Compliance in Deployment
- Secrets never stored in values.yaml; use Vault injection
- OPA policy checks during CI/CD and in cluster for in-flight manifests
- Image scanners (Trivy) integrated in CI
