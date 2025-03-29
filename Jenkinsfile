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
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t python-demo:${BUILD_NUMBER} .'
                sh 'docker tag python-demo:${BUILD_NUMBER} python-demo:latest'
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                docker stop python-demo || true
                docker rm python-demo || true
                docker run -d --name python-demo -p 5000:5000 python-demo:latest
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
    }
}
