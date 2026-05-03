#!/bin/bash
set -euo pipefail

echo "Waiting for Vault pods to be ready..."
kubectl wait --for=condition=Ready pod/vault-0 -n vault --timeout=300s

echo "Initializing Vault..."
VAULT_INIT=$(kubectl exec -n vault vault-0 -- vault operator init -format=json)
echo "$VAULT_INIT" > vault-init.json

UNSEAL_KEY=$(echo "$VAULT_INIT" | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(echo "$VAULT_INIT" | jq -r '.root_token')

echo "Unsealing Vault..."
kubectl exec -n vault vault-0 -- vault operator unseal "$UNSEAL_KEY"

echo "Logging into Vault..."
kubectl exec -n vault vault-0 -- vault login "$ROOT_TOKEN"

echo "Enabling Kubernetes Auth Method..."
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

echo "Configuring Kubernetes Auth Method..."
# Get the internal API server address
K8S_HOST=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')

kubectl exec -n vault vault-0 -- vault write auth/kubernetes/config \
    kubernetes_host="$K8S_HOST"

echo "Creating Vault Policy for Blog App..."
kubectl exec -n vault vault-0 -- /bin/sh -c "echo 'path \"secret/data/gblog/*\" { capabilities = [\"read\"] }' > /tmp/blog-policy.hcl"
kubectl exec -n vault vault-0 -- vault policy write blog-policy /tmp/blog-policy.hcl

echo "Creating Kubernetes Auth Role..."
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/blog-role \
    bound_service_account_names=gblog-backend \
    bound_service_account_namespaces=gblog \
    policies=blog-policy \
    ttl=24h

echo "Vault bootstrapping complete. Root token and unseal keys are in vault-init.json (KEEP SECURE!)"
