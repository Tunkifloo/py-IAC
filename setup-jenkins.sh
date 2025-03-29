#!/bin/bash

# Asegurar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Asegurar que el usuario actual tenga permisos para Docker
if ! groups | grep -q docker; then
    echo "Añadiendo usuario $(whoami) al grupo docker..."
    sudo usermod -aG docker $(whoami)
    echo "⚠️ IMPORTANTE: Necesitas cerrar sesión y volver a iniciarla para que los cambios surtan efecto."
    echo "Alternativamente, puedes ejecutar: 'newgrp docker' para aplicar los cambios en la sesión actual."
    
    # Aplicar los cambios en la sesión actual
    echo "Intentando aplicar cambios a la sesión actual..."
    newgrp docker << EONG
    echo "Permisos de Docker actualizados para la sesión actual."
EONG
fi

# Verificar que el servicio Docker esté en ejecución
if ! sudo systemctl is-active --quiet docker; then
    echo "Iniciando el servicio Docker..."
    sudo systemctl start docker
fi

# Asegurar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose no está instalado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Probar si tenemos permisos para ejecutar Docker
if ! docker ps > /dev/null 2>&1; then
    echo "⚠️ Todavía no tienes permisos para ejecutar Docker sin sudo."
    echo "Por ahora, usaremos sudo para ejecutar los comandos de Docker."
    
    # Iniciar los contenedores con sudo
    echo "Iniciando contenedores con Docker Compose usando sudo..."
    sudo docker-compose up -d
    
    # Esperar a que Jenkins esté disponible
    echo "Esperando a que Jenkins esté disponible..."
    until $(curl --output /dev/null --silent --head --fail http://localhost:8080/login); do
        printf '.'
        sleep 5
    done
    
    # Obtener la contraseña inicial de Jenkins
    echo -e "\nObteniendo contraseña inicial de Jenkins..."
    sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
else
    # Iniciar los contenedores sin sudo
    echo "Iniciando contenedores con Docker Compose..."
    docker-compose up -d
    
    # Esperar a que Jenkins esté disponible
    echo "Esperando a que Jenkins esté disponible..."
    until $(curl --output /dev/null --silent --head --fail http://localhost:8080/login); do
        printf '.'
        sleep 5
    done
    
    # Obtener la contraseña inicial de Jenkins
    echo -e "\nObteniendo contraseña inicial de Jenkins..."
    docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
fi

echo -e "\nJenkins está listo para su configuración inicial en: http://localhost:8080"
echo "Use la contraseña mostrada arriba para el desbloqueo inicial."
echo -e "\nRecuerde instalar los siguientes plugins en Jenkins:"
echo "- Docker Pipeline"
echo "- Blue Ocean"
echo "- Git Integration"
echo "- Pipeline Utility Steps"

echo -e "\nAplicación Flask disponible en: http://localhost:5000"
