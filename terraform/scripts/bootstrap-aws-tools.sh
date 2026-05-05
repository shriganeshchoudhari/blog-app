#!/bin/bash
# Fixed Bootstrap Script for G-Blog X (Ubuntu 24.04 Noble)

# 1. Update and Base Tools
sudo apt update -y
sudo apt install -y docker.io wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release fontconfig unzip git

# 2. Docker Setup
sudo systemctl enable docker --now
sudo usermod -aG docker ubuntu

# 3. Jenkins Installation (User Confirmed Working Logic)
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Trivy Security (Binary Keyring Fix)
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/trivy.gpg
echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list

# 5. Install Software
sudo apt update -y
# Using native Ubuntu 21 JDK for stability
sudo apt install -y openjdk-21-jdk maven jenkins trivy

# 6. CLI Tools
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# 7. Final Configuration
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Start SonarQube container
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

echo "Bootstrap Complete."
