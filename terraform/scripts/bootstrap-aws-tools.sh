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

# 7. Jenkins Configuration as Code (JCasC) Setup
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo mkdir -p /var/lib/jenkins/casc_configs

# Install Jenkins Plugin Manager
JAR_URL="https://github.com/jenkinsci/plugin-installation-manager-tool/releases/latest/download/jenkins-plugin-manager.jar"
sudo wget -q $JAR_URL -O /opt/jenkins-plugin-manager.jar

# Create plugins.txt
sudo tee /var/lib/jenkins/plugins.txt <<EOF
configuration-as-code:1930.v2d0658f800c1
git:5.7.0
workflow-aggregator:602.v85e06ec0dd97
docker-workflow:580.vc0c340686b_54
sonar:2.18.2
aws-credentials:247.v865d3d9cda_f0
pipeline-aws:1.95.ve3607062400a_
slack:741.v981d305cc860
blueocean:1.27.16
amazon-ecr:209.v67b_d6756209b_
kubernetes:4349.v87f340f1a_759
dark-theme:721.ve589d891b_5e1
EOF

# Install Plugins
sudo java -jar /opt/jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war --plugin-file /var/lib/jenkins/plugins.txt --plugin-download-directory /var/lib/jenkins/plugins

# Create jenkins.yaml
sudo tee /var/lib/jenkins/jenkins.yaml <<EOF
jenkins:
  systemMessage: "G-Blog X Jenkins configured via Configuration as Code (JCasC)"
  numExecutors: 2
  scmCheckoutRetryCount: 2
  mode: NORMAL
  securityRealm:
    local:
      allowsSignup: false
      enableCaptcha: false
      users:
        - id: "admin"
          password: "$${ADMIN_PASSWORD}"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

unclassified:
  sonarGlobalConfiguration:
    server:
      - name: "SonarQube"
        serverUrl: "http://localhost:9000"
        credentialsId: "sonar-token"
        installations:
          - name: "SonarScanner"

tool:
  maven:
    installations:
      - name: "maven-3.9"
        home: "/usr/share/maven"
  jdk:
    installations:
      - name: "jdk-21"
        home: "/usr/lib/jvm/java-21-openjdk-amd64"
  dockerTool:
    installations:
      - name: "docker"
        home: "/usr/bin/docker"

credentials:
  system:
    domainCredentials:
      - credentials:
          - string:
              scope: GLOBAL
              id: "sonar-token"
              secret: "$${SONAR_TOKEN}"
          - aws:
              scope: GLOBAL
              id: "aws-creds"
              accessKey: "$${AWS_ACCESS_KEY_ID}"
              secretKey: "$${AWS_SECRET_ACCESS_KEY}"
          - usernamePassword:
              scope: GLOBAL
              id: "docker-hub"
              username: "$${DOCKER_HUB_USER}"
              password: "$${DOCKER_HUB_TOKEN}"
EOF

# 8. Final Configuration
sudo usermod -aG docker jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins/

# Configure JCasC Environment Variable
sudo mkdir -p /etc/systemd/system/jenkins.service.d
echo "[Service]
Environment=\"CASC_JENKINS_CONFIG=/var/lib/jenkins/jenkins.yaml\"
Environment=\"ADMIN_PASSWORD=$ADMIN_PASSWORD\"
Environment=\"SONAR_TOKEN=$SONAR_TOKEN\"
Environment=\"DOCKER_HUB_USER=$DOCKER_HUB_USER\"
Environment=\"DOCKER_HUB_TOKEN=$DOCKER_HUB_TOKEN\"
Environment=\"AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\"
Environment=\"AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Start SonarQube container
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

echo "Bootstrap Complete."
