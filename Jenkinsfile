pipeline {
    agent any

    environment {
        // These will be injected from Jenkins/Terraform
        ECR_REPO = "${env.ECR_URL ?: '239013465815.dkr.ecr.us-east-1.amazonaws.com/gblog-app'}"
        AWS_REGION = "us-east-1"
        SCANNER_HOME = tool 'SonarScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=gblog-app -Dsonar.java.binaries=target/classes"
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Authenticate with ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                    
                    // Build the image
                    sh "docker build -t ${ECR_REPO}:${GIT_COMMIT} ."
                    
                    // Push the image
                    sh "docker push ${ECR_REPO}:${GIT_COMMIT}"
                }
            }
        }

        stage('Update Manifest (GitOps)') {
            steps {
                script {
                    // Update the image tag in deployment.yaml
                    sh "sed -i 's|image: .*|image: ${ECR_REPO}:${GIT_COMMIT}|g' k8s/deployment.yaml"
                    
                    // Commit and push back to repo
                    withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh "git config user.email 'jenkins@shriganesh.me'"
                        sh "git config user.name 'Jenkins CI'"
                        sh "git add k8s/deployment.yaml"
                        sh "git commit -m 'chore: update image to ${GIT_COMMIT} [skip ci]'"
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
