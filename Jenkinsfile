pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                // Make sure files exist after checkout
                sh 'ls -la'
                sh 'pwd'
            }
        }
        
        stage('Test in Container') {
            steps {
                // Create a requirements file first to ensure it exists
                sh 'cat requirements.txt'
                
                // Run tests in container with improved volume mounting
                sh '''
                docker run --rm \
                    -v "${WORKSPACE}:/workspace:rw" \
                    -w /workspace \
                    python:3.11-slim bash -c "
                        echo '===== DEBUGGING ====='
                        ls -la
                        pwd
                        echo '===== CONTENT OF REQUIREMENTS.TXT ====='
                        cat requirements.txt
                        echo '===== INSTALLING DEPENDENCIES ====='
                        pip install -r requirements.txt
                        pip install pytest bandit
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