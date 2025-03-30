pipeline {
    agent {
        docker {
            image 'python:3.11-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    stages {
        stage('Prepare') {
            steps {
                sh 'apt-get update && apt-get install -y docker.io'
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
                sh 'pip install pytest bandit'
            }
        }
        
        stage('Test') {
            steps {
                sh 'python -m pytest tests/'
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'bandit -r app.py'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t python-demo:${BUILD_NUMBER} .'
                sh 'docker tag python-demo:${BUILD_NUMBER} python-demo:latest'
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                docker stop python-IAC || true
                docker rm python-IAC || true
                docker run -d --name python-IAC \
                  --network python-flask-demo_app-network \
                  -p 5000:5000 \
                  -e DEBUG_MODE=False \
                  python-demo:latest
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Aplicación desplegada correctamente'
        }
        failure {
            echo 'Falló el pipeline'
        }
        always {
            sh 'docker image prune -f'
        }
    }
}
