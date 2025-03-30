pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Debug Workspace') {
            steps {
                // Explorar el contenido del workspace para debug
                sh '''
                echo "Contenido del workspace:"
                ls -la
                echo "Verificando si existe requirements.txt:"
                test -f requirements.txt && echo "Existe" || echo "No existe"
                '''
            }
        }
        
        stage('Test in Container') {
            steps {
                // Primero creamos un requirements.txt mínimo si no existe
                sh '''
                if [ ! -f requirements.txt ]; then
                    echo "Creando archivo requirements.txt mínimo"
                    echo "flask==2.3.3" > requirements.txt
                    echo "pytest==7.4.0" >> requirements.txt
                fi
                '''
                
                // Ejecutar pruebas en un contenedor Python
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