pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test in Container') {
            steps {
                // Ejecutar pruebas en un contenedor Python sin instalar Docker
                sh '''
                docker run --rm -v ${WORKSPACE}:/app -w /app python:3.11-slim bash -c "
                    pip install -r requirements.txt pytest bandit &&
                    python -m pytest tests/ &&
                    bandit -r app.py
                "
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Construir imagen usando el Docker del host
                sh '''
                docker build -t python-demo:${BUILD_NUMBER} .
                docker tag python-demo:${BUILD_NUMBER} python-demo:latest
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                // Desplegar usando el Docker del host
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