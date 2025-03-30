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
                // Enfoque directo: crear el archivo requirements.txt dentro del contenedor
                sh '''
                docker run --rm \
                    -v ${WORKSPACE}:/workspace \
                    -w /workspace \
                    python:3.11-slim bash -c "
                        echo '===== DEBUGGING ====='
                        ls -la
                        echo '===== CONTENT OF REQUIREMENTS.TXT ====='
                        cat requirements.txt
                        echo '===== INSTALLING DEPENDENCIES ====='
                        pip install -r requirements.txt pytest bandit
                        echo '===== RUNNING TESTS ====='
                        python -m pytest tests/
                        echo '===== RUNNING SECURITY SCAN ====='
                        bandit -r app.py
                    "
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t python-demo:${BUILD_NUMBER} .
                docker tag python-demo:${BUILD_NUMBER} python-demo:latest
                '''
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
            // Limpiar imágenes antiguas
            sh 'docker image prune -f'
        }
    }
}