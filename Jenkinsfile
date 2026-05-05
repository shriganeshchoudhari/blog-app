@Library('Shared') _

pipeline {
    agent any
    
    parameters {
        string(name: 'BACKEND_TAG', defaultValue: 'latest', description: 'Tag for Backend Image')
        string(name: 'FRONTEND_TAG', defaultValue: 'latest', description: 'Tag for Frontend Image')
        booleanParam(name: 'RUN_SECURITY_SCAN', defaultValue: true, description: 'Run Trivy and SonarQube')
    }

    environment {
        DOCKER_REPO = 'shriganeshdockerhub' // Your DockerHub username
        SONAR_SERVER = 'Sonar'              // Must match Manage Jenkins > System
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Security: SonarQube Scan') {
            when { expression { return params.RUN_SECURITY_SCAN } }
            steps {
                sonarScan(
                    projectKey: 'gblog-backend',
                    credentialsId: 'sonar-token'
                )
            }
        }

        stage('Build & Push: Backend') {
            steps {
                dir('backend-spring-boot') {
                    dockerBuild(
                        imageName: 'gblog-backend',
                        imageTag: "${params.BACKEND_TAG}",
                        registry: "${DOCKER_REPO}/",
                        credentialsId: 'docker-creds'
                    )
                }
            }
        }

        stage('Build & Push: Frontend') {
            steps {
                dir('frontend') {
                    dockerBuild(
                        imageName: 'gblog-frontend',
                        imageTag: "${params.FRONTEND_TAG}",
                        registry: "${DOCKER_REPO}/",
                        credentialsId: 'docker-creds'
                    )
                }
            }
        }

        stage('Security: Trivy Scan') {
            when { expression { return params.RUN_SECURITY_SCAN } }
            steps {
                parallel {
                    stage('Trivy: Backend') {
                        steps {
                            trivyScan(
                                imageName: "${DOCKER_REPO}/gblog-backend",
                                imageTag: "${params.BACKEND_TAG}"
                            )
                        }
                    }
                    stage('Trivy: Frontend') {
                        steps {
                            trivyScan(
                                imageName: "${DOCKER_REPO}/gblog-frontend",
                                imageTag: "${params.FRONTEND_TAG}"
                            )
                        }
                    }
                }
            }
        }

        stage('Deploy: ArgoCD Sync') {
            steps {
                argocdSync(
                    appName: 'gblog-app'
                )
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Successfully deployed version ${params.BACKEND_TAG} to EKS!"
        }
    }
}
