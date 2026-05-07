#!/bin/bash
set -e

# 1. Install Jenkins Plugin Manager
JAR_URL="https://github.com/jenkinsci/plugin-installation-manager-tool/releases/latest/download/jenkins-plugin-manager.jar"
sudo wget -q $JAR_URL -O /opt/jenkins-plugin-manager.jar

# 2. Install Plugins
# We assume plugins.txt and jenkins.yaml are copied to /var/lib/jenkins/
sudo java -jar /opt/jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war --plugin-file /var/lib/jenkins/plugins.txt --plugin-download-directory /var/lib/jenkins/plugins

# 3. Set ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins

# 4. Configure JCasC
# Add environment variable to jenkins service
sudo mkdir -p /etc/systemd/system/jenkins.service.d
echo "[Service]
Environment=\"CASC_JENKINS_CONFIG=/var/lib/jenkins/jenkins.yaml\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# 5. Restart Jenkins
sudo systemctl daemon-reload
sudo systemctl restart jenkins
