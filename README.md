# 🚀 G-Blog X: The Ultimate Cloud-Native Microservices Platform

**G-Blog X** is a state-of-the-art, production-ready blogging platform built with a **Zero-Trust** architecture, **GitOps** delivery, and **Deep Observability**. It serves as a gold standard for modern full-stack development and DevOps automation.

---

## 🏗 Architecture Overview

| Layer | Technologies |
| :--- | :--- |
| **Frontend** | React 18+, Vite, Axios (with Auth Interceptors), Glassmorphism UI |
| **Backend** | Java 21, Spring Boot 3.3.5, Spring Security, JJWT 0.12, Flyway |
| **Infrastructure** | AWS (EKS, RDS Postgres, VPC, NAT Gateway), Terraform |
| **CI/CD** | Jenkins (Shared Libraries), GitHub Actions, Docker Hub |
| **GitOps** | ArgoCD, Argo Rollouts (Canary Deployment) |
| **Security** | HashiCorp Vault (Sidecar Injection), OPA Gatekeeper, SonarQube, Trivy, OWASP |
| **Observability** | Prometheus, Grafana, Loki (Logging), OpenTelemetry |

---

## ✨ Key Features

- **Progressive Delivery**: Canary deployments using Argo Rollouts with automated analysis and rollback.
- **Zero-Trust Secrets**: Database credentials and JWT secrets are never in plain text; they are injected by Vault at runtime.
- **Unified Observability**: Correlated metrics, logs, and traces (OTel) in a single Grafana dashboard.
- **Hardened Security**: Every build undergoes OWASP library scans, SonarQube code analysis, and Trivy container scanning.
- **Persistent Sessions**: Advanced JWT Auth with Refresh Token rotation handled via Axios interceptors.

---

## 🛠 Deployment Guide

### Prerequisites
- **AWS CLI**: Installed and configured (`aws configure`).
- **Terraform**: >= 1.5
- **kubectl & Helm**: For cluster management.
- **Docker Hub**: Account and credentials.

### 1. Provision Infrastructure
Create the VPC, EKS, RDS, and the CI server.
```bash
cd terraform
# Generate keys for the CI node
ssh-keygen -t rsa -b 4096 -f terra-key -N ""

terraform init
terraform apply -auto-approve
```

### 2. Bootstrap Cluster Tools
Install the management layer (ArgoCD, Vault, Prometheus, Ingress, etc.) onto the EKS cluster.
```bash
# Log into CI server or use local terminal with kubeconfig
chmod +x terraform/scripts/install-cluster-tools.sh
./terraform/scripts/install-cluster-tools.sh
```

### 3. Initialize Vault Security
Unseal Vault and configure the Kubernetes Auth method for secret injection.
```bash
chmod +x terraform/scripts/bootstrap-vault.sh
./terraform/scripts/bootstrap-vault.sh
```

### 4. Trigger the Pipeline
- **Jenkins**: Configure a pipeline using the provided `Jenkinsfile`. Add `dockerhub-creds` and `github-creds`.
- **GitHub Actions**: Add your secrets (`DOCKER_USERNAME`, `SONAR_TOKEN`, etc.) and push to `main`.

### 5. Verify & Access
Get the public URL for your blog:
```bash
kubectl get ingress -n gblog
```

---

## 📁 Project Structure

```text
├── .github/workflows/    # GitHub Actions CI/CD
├── backend-spring-boot/  # Java 21 Microservice
├── frontend/             # React SPA
├── helm/                 # Kubernetes Charts
├── jenkins-shared-library/# Modular Jenkins Logic
├── terraform/            # AWS Infrastructure
│   ├── scripts/          # Automation Shell Scripts
└── opa/                  # Open Policy Agent Rules
```

---

## 🛡 Security Compliance
G-Blog X follows **Shift-Left Security** principles. All code is scanned before it leaves the developer's machine (via GitHub Actions) and again before production (via Jenkins).

- **SCA**: OWASP Dependency Check
- **SAST**: SonarQube
- **CS**: Trivy Container Scan
- **Gating**: OPA Gatekeeper Admission Controller

---

## 👨‍💻 Author
**Shriganesh Choudhari** 


---
*G-Blog X - Built for scale, secured for production.*
