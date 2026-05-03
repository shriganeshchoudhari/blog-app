#!/bin/bash
set -euo pipefail
LOGFILE=/var/log/bootstrap-aws-tools.log
exec > >(tee -a $LOGFILE) 2>&1

echo "Bootstrapping AWS CI node with required tools..."
sudo apt-get update -y
sudo apt-get install -y docker.io apt-transport-https ca-certificates curl software-properties-common lsb-release gnupg
sudo systemctl enable docker --now
sudo usermod -aG docker ubuntu

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Installing AWS CLI..."
sudo snap install aws-cli --classic

echo "Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Installing Java 21 & Maven..."
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jdk maven

echo "Installing Jenkins..."
# Add Jenkins repo and key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Installing Git & ArgoCD CLI..."
sudo apt-get install -y git
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

echo "Starting SonarQube Server..."
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

sudo systemctl restart jenkins

echo "Bootstrap complete."
echo "Tools installed: docker, kubectl, awscli, helm, java17, maven, git, jenkins"
echo "Initial Jenkins Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
