#!/bin/bash
# Bootstrap Script for G-Blog X CI Node (Ubuntu 24.04 LTS)

# 1. Update and Base Tools
sudo apt update -y
sudo apt install -y docker.io wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release fontconfig unzip

# 2. Docker Setup
sudo systemctl enable docker --now
sudo usermod -aG docker ubuntu

# 3. Jenkins Installation
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Java 21 (Adoptium) & Maven
# Note: Adoptium supports 'noble' from temurin repos directly
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb jammy main" | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null

# 5. Trivy Security
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/trivy.gpg
echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list

# 6. Install All Software
sudo apt update -y
sudo apt install -y jenkins temurin-21-jdk maven trivy git

# 7. CLI Tools (kubectl, awscli, helm, argocd)
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# AWS CLI v2 (binary install - works on all Ubuntu versions)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# 8. Final Configuration
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Start SonarQube container
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

echo "Bootstrap Complete."
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
