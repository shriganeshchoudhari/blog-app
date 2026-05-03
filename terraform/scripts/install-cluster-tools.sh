#!/bin/bash
set -euo pipefail

echo "Configuring kubectl for EKS cluster..."
# This assumes the user has AWS credentials configured on the CI node
aws eks update-kubeconfig --region us-east-1 --name gblog-eks

echo "Installing ArgoCD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Installing Argo Rollouts..."
kubectl create namespace argo-rollouts || true
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

echo "Installing HashiCorp Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install vault hashicorp/vault --namespace vault --create-namespace

echo "Installing OPA Gatekeeper..."
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update
helm upgrade --install gatekeeper gatekeeper/gatekeeper --namespace gatekeeper-system --create-namespace

echo "Installing NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

echo "Installing Prometheus & Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

echo "Installing Loki & Promtail (Logging)..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki-stack --namespace monitoring --set grafana.enabled=false

echo "Installing OpenTelemetry Operator (for AI Insights)..."
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm upgrade --install otel-operator open-telemetry/opentelemetry-operator --namespace observability --create-namespace --set manager.collectorImage.repository=otel/opentelemetry-collector-contrib

echo "Cluster tools installation complete."
