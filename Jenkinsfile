pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO       = 'aminata286'
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_SESSION_TOKEN     = credentials('aws-session-token')
        AWS_DEFAULT_REGION    = 'us-west-2'
    }

    triggers {
        // Déclenchement automatique via webhook GitHub
        GenericTrigger(
            genericVariables: [
                [key: 'ref', value: '$.ref'],
                [key: 'pusher_name', value: '$.pusher.name'],
                [key: 'commit_message', value: '$.head_commit.message']
            ],
            causeString: 'Push par $pusher_name sur $ref: "$commit_message"',
            token: 'mysecret',
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {

        // 🧩 Étape 1 : Récupération du code source
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[
                        credentialsId: 'credential-git',
                        url: 'https://github.com/Aminata11/jenkins-test.git'
                    ]]
                )
            }
        }

        // 🔑 Étape 2 : Connexion à Docker Hub
        stage('DockerHub Login') {
            steps {
                echo 'Connexion à Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'cred-hub-tera', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        // 🛠️ Étape 3 : Build Docker Images
        stage('Build Backend Image') {
            steps {
                echo 'Construction de l’image backend...'
                sh 'docker build -t $DOCKER_HUB_REPO/backend:latest ./mon-projet-express'
            }
        }

        stage('Build Frontend Image') {
            steps {
                echo 'Construction de l’image frontend...'
                sh 'docker build -t $DOCKER_HUB_REPO/frontend:latest ./'
            }
        }

        // 📤 Étape 4 : Push Docker Images
        stage('Push Images') {
            steps {
                echo 'Envoi des images vers Docker Hub...'
                sh '''
                    docker push $DOCKER_HUB_REPO/backend:latest
                    docker push $DOCKER_HUB_REPO/frontend:latest
                '''
            }
        }

        // 🚀 Étape 5 : Terraform Init & Apply
        stage('Terraform Init & Apply') {
            steps {
                echo 'Déploiement de l’infrastructure avec Terraform...'
                dir('./terraform') {
                    withEnv([
                        "AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}",
                        "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}",
                        "AWS_SESSION_TOKEN=${env.AWS_SESSION_TOKEN}",
                        "AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}"
                    ]) {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        // 📌 Étape 6 : Récupération des outputs Terraform
        stage('Get Terraform Outputs') {
            steps {
                dir('./terraform') {
                    script {
                        env.EC2_IP = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()
                        echo "EC2 Public IP: ${env.EC2_IP}"
                        env.DDB_TABLE = sh(script: "terraform output -raw dynamodb_table_name", returnStdout: true).trim()
                        echo "DynamoDB Table: ${env.DDB_TABLE}"
                    }
                }
            }
        }

        // 🐳 Étape 7 : Déploiement via Docker Compose
        stage('Deploy with Docker Compose') {
            steps {
                echo 'Déploiement via Docker Compose...'
                sh 'docker compose up -d'
            }
        }
    }

    // 📬 Post-pipeline
    post {
        success {
            emailext(
                subject: "✅ Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline réussi 🎉\nDétails : ${env.BUILD_URL}",
                to: "seckaminata87@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "❌ Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué 😞\nDétails : ${env.BUILD_URL}",
                to: "seckaminata87@gmail.com"
            )
        }
        always {
            echo 'Nettoyage des images et conteneurs Docker...'
            sh '''
                docker container prune -f
                docker image prune -f
                docker logout
            '''
        }
    }
}
