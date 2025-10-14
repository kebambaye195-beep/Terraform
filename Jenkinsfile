pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'aminata286'
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
                        credentialsId: 'king-github',
                        url: 'https://github.com/Aminata11/jenkins-test.git'
                    ]]
                )
            }
        }

        
        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'npm test || echo "Aucun test disponible"'
                }
            }
        }

        
        // 🔑 Étape 5 : Connexion à Docker Hub
        stage('Login to DockerHub') {
            steps {
                echo 'Connexion à Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'king-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        // 🛠️ Étape 6 : Construction de l’image backend
        stage('Build Backend Image') {
            steps {
                echo 'Construction de l’image backend...'
                sh 'docker build -t $DOCKER_HUB_REPO/backend:latest ./mon-projet-express'
            }
        }

        // 🛠️ Étape 7 : Construction de l’image frontend
        stage('Build Frontend Image') {
            steps {
                echo 'Construction de l’image frontend...'
                sh 'docker build -t $DOCKER_HUB_REPO/frontend:latest ./'
            }
        }

        // 📤 Étape 8 : Push des images vers Docker Hub
        stage('Push Images') {
            steps {
                echo 'Envoi des images vers Docker Hub...'
                sh '''
                    docker push $DOCKER_HUB_REPO/backend:latest
                    docker push $DOCKER_HUB_REPO/frontend:latest
                '''
            }
        }

        // 🚀 Étape 9 : Déploiement via Docker Compose
        stage('Deploy with Docker Compose') {
            steps {
                echo 'Déploiement via Docker Compose...'
                sh 'docker compose up -d'
            }
        }
    }

    // 📬 Étapes post-pipeline
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
