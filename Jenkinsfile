pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    environment {
        AWS_REGION   = "us-east-1"
        ECR_REPO     = "636812143095.dkr.ecr.us-east-1.amazonaws.com/springboot-demo"
        DOCKER_IMAGE = "springboot-demo"
        IMAGE_TAG    = "${BUILD_NUMBER}"
    }

    stages {

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests -B'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                    docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO}

                        docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                        docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${ECR_REPO}:latest

                        docker push ${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Update GitOps Repository') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {

                    sh """
                        rm -rf gitops-repo

                        git clone https://github.com/vamsi1184/gitops-repo.git
                        cd gitops-repo

                        git config user.email "vamsi.krishna.1184@gmail.com"
                        git config user.name "vamsi1184"

                        # Pull latest changes safely
                        git pull https://${GITHUB_TOKEN}@github.com/vamsi1184/gitops-repo.git main --rebase

                        # Update image tag
                        sed -i "s|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}|g" deployment.yaml

                        git add deployment.yaml
                        git commit -m "Update image to ${IMAGE_TAG}" || echo "No changes"

                        git push https://${GITHUB_TOKEN}@github.com/vamsi1184/gitops-repo.git HEAD:main
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build ${BUILD_NUMBER} completed successfully"
            echo "🚀 Image pushed: ${ECR_REPO}:${IMAGE_TAG}"
        }

        failure {
            echo "❌ Pipeline failed"
        }
    }
}