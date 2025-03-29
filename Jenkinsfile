pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test') {
            steps {
                sh 'pip install pytest'
                sh 'pip install -r requirements.txt'
                sh 'python -m pytest tests/'
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'pip install bandit'
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
                # Detener y eliminar el contenedor anterior si existe
                docker stop python-demo || true
                docker rm python-demo || true
                
                # Ejecutar el nuevo contenedor
                docker run -d --name python-demo \
                  --network app-network \
                  -p 5000:5000 \
                  -e DEBUG_MODE=False \
                  -e PORT=5000 \
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
            // Limpiar imágenes antiguas
            sh '''
            docker image prune -f
            '''
        }
    }
}