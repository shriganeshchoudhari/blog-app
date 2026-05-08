#!/bin/bash
# Fixed Bootstrap Script for G-Blog X (Ubuntu 24.04 Noble)

# 1. Update and Base Tools
sudo apt update -y
sudo apt install -y docker.io wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release fontconfig unzip git

# 2. Docker Setup
sudo systemctl enable docker --now
sudo usermod -aG docker ubuntu

# 3. Install Tools (Java 21, Docker, etc.)
sudo apt update
sudo apt install -y openjdk-21-jdk maven docker.io curl wget unzip git

# 4. Install Jenkins (User's preferred method)
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# 5. Trivy Security (Binary Keyring Fix)
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/trivy.gpg
echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list

# 6. Install Software
sudo apt update -y
sudo apt install -y trivy

# 7. Other Tools (Kubectl, Helm, etc.)
# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

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

# 7. Jenkins Groovy Init for Admin
sudo tee /var/lib/jenkins/init.groovy.d/basic-security.groovy <<EOF
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "${ADMIN_PASSWORD}")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

# 8. Jenkins Configuration as Code (JCasC) Setup
sudo mkdir -p /var/lib/jenkins/plugins
sudo mkdir -p /var/lib/jenkins/init.groovy.d

# Install Jenkins Plugin Manager (Fixed reliable URL)
JAR_URL="https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar"
sudo curl -L $JAR_URL -o /opt/jenkins-plugin-manager.jar

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
sudo /usr/bin/java -jar /opt/jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war --plugin-file /var/lib/jenkins/plugins.txt --plugin-download-directory /var/lib/jenkins/plugins || true

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
          - usernamePassword:
              scope: GLOBAL
              id: "github-creds"
              username: "$${GITHUB_USER}"
              password: "$${GITHUB_TOKEN}"
EOF

# 8. Final Configuration
sudo usermod -aG docker jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins/

# Handle GitHub SSH Verification
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins ssh-keyscan github.com >> /var/lib/jenkins/.ssh/known_hosts

# Configure Environment (Fixing Java Detection)
sudo tee /etc/default/jenkins <<EOF
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
JENKINS_JAVA_CMD=/usr/bin/java
CASC_JENKINS_CONFIG=/var/lib/jenkins/jenkins.yaml
ADMIN_PASSWORD=${ADMIN_PASSWORD}
SONAR_TOKEN=${SONAR_TOKEN}
DOCKER_HUB_USER=${DOCKER_HUB_USER}
DOCKER_HUB_TOKEN=${DOCKER_HUB_TOKEN}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
GITHUB_USER=${GITHUB_USER}
GITHUB_TOKEN=${GITHUB_TOKEN}
WEBHOOK_SECRET=${WEBHOOK_SECRET}
ECR_URL=${ECR_URL}
EOF

# Systemd Override
sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo tee /etc/systemd/system/jenkins.service.d/override.conf <<EOF
[Service]
EnvironmentFile=/etc/default/jenkins
# Force Java Path
ExecStart=
ExecStart=/usr/bin/java -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080
EOF

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl restart jenkins

# Start SonarQube container
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

echo "Bootstrap Complete."
