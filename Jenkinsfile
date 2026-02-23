pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/springboot-demo"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    stages {
        stage ('scm checkout') {
            steps {
                sh 'git clone https://github.com/vamsi1184/springboot-demo.git'
            }
        }
        stage ('build') {
            steps {
                sh 'cd springboot-demo && ./mvnw clean package -DskipTests'
            }
        }
        stage ('source code analysis') {
            steps {
                sh 'cd springboot-demo && ./mvnw sonar:sonar -Dsonar.projectKey=springboot-demo -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=admin'
            }
        }
        stage ('build docker image') {
            steps {
                sh 'cd springboot-demo && docker build -t springboot-demo:latest .'
            }
        }
        stage ('push docker image to ECR') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com'
                sh 'docker tag springboot-demo:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/springboot-demo:latest'
                sh 'docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/springboot-demo:latest'
            }
        }
        stage ('image update in gitops repo') {
            steps {
                sh """git clone https://github.com/vamsi1184/gitops-repo.git
                cd gitops-repo
                sed -i 's|springboot-demo:latest|<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/springboot-demo:latest|g' springboot-demo.yaml
                git add springboot-demo.yaml
                git commit -m "Update springboot-demo image"
                git push origin update-image
                """
            }
        }
    }
}