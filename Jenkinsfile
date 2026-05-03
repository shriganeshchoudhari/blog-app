@Library('my-shared-library') _

pipeline {
  agent any
  
  environment {
    DOCKER_REGISTRY = "docker.io/"
    IMAGE_NAME = "gblog-backend"
    IMAGE_TAG = "v${env.BUILD_NUMBER}"
    AWS_REGION = "us-east-1"
    CLUSTER_NAME = "gblog-eks"
    APP_NAME = "gblog-app"
  }

  stages {
    stage('Prepare Environment') {
      steps {
        gitSetup credentialsId: 'github-creds'
        argocdLogin server: 'argocd.example.com', credentialsId: 'argocd-creds'
        terraformApply dir: 'terraform'
      }
    }

    stage('Infrastructure Setup') {
      steps {
        sh 'chmod +x terraform/scripts/install-cluster-tools.sh'
        sh './terraform/scripts/install-cluster-tools.sh'
      }
    }

    stage('Build & Code Analysis') {
      parallel {
        stage('Maven Build') {
          steps {
            mavenBuild dir: 'backend-spring-boot', skipTests: false
          }
        }
        stage('SonarQube Analysis') {
          steps {
            sonarScan projectKey: 'gblog-backend'
          }
        }
      }
    }

    stage('Security Gating') {
      parallel {
        stage('OWASP Dependency Check') {
          steps {
            dir('backend-spring-boot') {
              sh 'mvn org.owasp:dependency-check-maven:check'
              dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
          }
        }
        stage('Container Scan (Trivy)') {
          steps {
            trivyScan imageName: IMAGE_NAME, imageTag: IMAGE_TAG
          }
        }
      }
    }

    stage('Build & Push to DockerHub') {
      steps {
        dockerBuild(
          imageName: IMAGE_NAME, 
          imageTag: IMAGE_TAG, 
          context: './backend-spring-boot',
          registry: DOCKER_REGISTRY,
          credentialsId: 'dockerhub-creds'
        )
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 1, unit: 'HOURS') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('GitOps Sync') {
      steps {
        sh "sed -i 's|repository:.*|repository: ${DOCKER_REGISTRY}${IMAGE_NAME}|' helm/gblog/values-prod.yaml"
        sh "sed -i 's|tag:.*|tag: ${IMAGE_TAG}|' helm/gblog/values-prod.yaml"
        sh "git add helm/gblog/values-prod.yaml"
        sh "git commit -m 'chore: update image to ${DOCKER_REGISTRY}${IMAGE_NAME}:${IMAGE_TAG} [skip ci]' || true"
        sh "git push origin main"
        
        argocdSync appName: APP_NAME
      }
    }
  }

  post {
    always {
      echo "Build finished."
    }
  }
}
