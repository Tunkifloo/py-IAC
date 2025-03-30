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
                // Copiar archivos necesarios al directorio temporal compartido
                sh '''
                mkdir -p /tmp/jenkins/build
                cp -R * /tmp/jenkins/build/
                ls -la /tmp/jenkins/build/
                '''
                
                // Ejecutar pruebas usando el directorio compartido
                sh '''
                docker run --rm -v jenkins_tmp:/tmp/jenkins \
                           -v build_cache:/cache \
                           -w /tmp/jenkins/build python:3.11-slim bash -c "
                    echo 'Instalando dependencias...' &&
                    pip install --cache-dir=/cache/pip -r requirements.txt pytest bandit &&
                    echo 'Ejecutando pruebas...' &&
                    python -m pytest tests/ &&
                    echo 'Ejecutando análisis de seguridad...' &&
                    bandit -r app.py
                "
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Construir imagen desde el directorio compartido para aprovechar caché
                sh '''
                cd /tmp/jenkins/build
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
            
            // Limpiar directorio temporal
            sh 'rm -rf /tmp/jenkins/build || true'
        }
    }
}