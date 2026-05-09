pipeline {
    agent any

    environment {
        // These will be injected from Jenkins/Terraform
        ECR_REGISTRY = "239013465815.dkr.ecr.us-east-1.amazonaws.com"
        BACKEND_REPO = "${ECR_REGISTRY}/gblog-backend"
        FRONTEND_REPO = "${ECR_REGISTRY}/gblog-frontend"
        AWS_REGION = "us-east-1"
        SCANNER_HOME = tool 'SonarScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend Build & Test') {
            steps {
                dir('backend-spring-boot') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('Frontend Build & Test') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'npm run build'
                    // sh 'npm run test' // Uncomment when tests are stable
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    dir('backend-spring-boot') {
                        sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=gblog-backend -Dsonar.java.binaries=target/classes"
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Authenticate with ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    
                    // Build & Push Backend
                    sh "docker build -t ${BACKEND_REPO}:${GIT_COMMIT} -t ${BACKEND_REPO}:latest backend-spring-boot"
                    sh "docker push ${BACKEND_REPO}:${GIT_COMMIT}"
                    sh "docker push ${BACKEND_REPO}:latest"
                    
                    // Build & Push Frontend
                    sh "docker build -t ${FRONTEND_REPO}:${GIT_COMMIT} -t ${FRONTEND_REPO}:latest frontend"
                    sh "docker push ${FRONTEND_REPO}:${GIT_COMMIT}"
                    sh "docker push ${FRONTEND_REPO}:latest"
                }
            }
        }

        stage('Update Helm Manifest (GitOps)') {
            steps {
                script {
                    // Update image tags in values-aws-deploy.yaml
                    sh "sed -i 's|tag: .*|tag: \"${GIT_COMMIT}\"|g' helm/gblog/values-aws-deploy.yaml"
                    
                    // Commit and push back to repo
                    withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh "git config user.email 'jenkins@shriganesh.me'"
                        sh "git config user.name 'Jenkins CI'"
                        sh "git add helm/gblog/values-aws-deploy.yaml"
                        sh "git commit -m 'chore: update deployment tag to ${GIT_COMMIT} [skip ci]'"
                        sh "git push https://${GIT_TOKEN}@github.com/shriganeshchoudhari/blog-app.git HEAD:main"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
