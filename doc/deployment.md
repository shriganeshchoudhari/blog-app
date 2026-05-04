# G-Blog X: Full Deployment Guide

This document provides the definitive guide to deploying the G-Blog X platform on AWS from scratch.

## 1. Prerequisites
- **AWS CLI**: Installed and authenticated.
- **Terraform**: v1.5.0 or higher.
- **SSH Client**: For key generation and CI node access.

## 2. Phase 0: Authentication
Before running any Terraform commands, you must authenticate your local session with AWS.
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, Region (us-east-1), and Output (json)
```

## 3. Phase 1: Infrastructure Provisioning
Navigate to the `terraform/` directory to begin.

### 2.1 Generate SSH Keys
Generate a dedicated key pair for the Jenkins CI node.
```bash
cd terraform
ssh-keygen -t rsa -b 4096 -f terra-key -N ""
```

### 2.2 Terraform Rollout
Initialize and apply the infrastructure. This process takes approximately **15-20 minutes**.
```bash
terraform init
terraform apply -auto-approve
```
*Note: Copy the `ci_public_ip` from the output.*

## 3. Phase 2: CI/CD & Cluster Bootstrapping
Wait 5 minutes after Terraform completes for the `bootstrap-aws-tools.sh` to finish installing Jenkins.

### 3.1 Cluster Management Tools
Install ArgoCD, Vault, Prometheus, and OTel onto the EKS cluster.
```bash
chmod +x scripts/install-cluster-tools.sh
./scripts/install-cluster-tools.sh
```

### 3.2 Vault Security Initialization
Initialize and unseal Vault to enable secret injection for the microservices.
```bash
chmod +x scripts/bootstrap-vault.sh
./scripts/bootstrap-vault.sh
```

## 4. Phase 3: Application Rollout
### 4.1 Jenkins Configuration
1. Access Jenkins at `http://<ci_public_ip>:8080`.
2. Initial password is in `/var/log/bootstrap-aws-tools.log` on the CI node.
3. Configure the **GitHub Shared Library** and add your credentials (`dockerhub-creds`, `github-creds`).

### 4.2 GitOps Trigger
Push your code to the `main` branch. Jenkins will detect the change, build the image, and ArgoCD will automatically begin the **Canary Rollout**.

## 5. Verification
- **App URL**: Retrieve the Load Balancer DNS from the Ingress resource.
- **ArgoCD Dashboard**: Port-forward to the ArgoCD server to watch the rollout analysis.
