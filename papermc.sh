apt --assume-yes update && apt --assume-yes upgrade
apt install --assume-yes screen
apt install --assume-yes ttyd  
apt install --assume-yes openjdk-17-jre-headless
apt install --assume-yes openjdk-16-jre-headless
apt install --assume-yes openjdk-11-jre-headless
apt install --assume-yes openjdk-8-jre-headless
apt install --assume-yes jq
apt install --assume-yes curl
curl https://raw.githubusercontent.com/ALFREDYTX/Cloudvgs/main/start.sh --output /start.sh
curl https://raw.githubusercontent.com/ALFREDYTX/Cloudvgs/main/stop.sh --output /stop.sh
chmod +x /start.sh
chmod +x /stop.sh

# Solicitar el nombre del usuario
read -p "Ingrese el nombre del usuario: " username

# Agregar usuario interactivo
sudo useradd $username

# Crear el directorio raíz del usuario
sudo mkdir /home/$username

# Establecer el propietario y el grupo del directorio
sudo chown $username:$username /home/$username

# Establecer la contraseña de manera no interactiva
echo "$username:12345" | sudo chpasswd

read -p "Ingrese la versión de Minecraft: " version

PROJECT=paper
MINECRAFT_VERSION=$version

# Verificar si la versión especificada existeEOF
VER_EXISTS=$(curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true)
LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r '.versions' | jq -r '.[-1]')

if [ -z "${VER_EXISTS}" ]; then
    echo "Error: Specified version ${MINECRAFT_VERSION} not found for project ${PROJECT}"
    exit 1
fi

# Obtener información sobre la versión y la compilación
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]')

if [ -z "${LATEST_BUILD}" ]; then
    echo "Error: Unable to retrieve the latest build for version ${MINECRAFT_VERSION} of project ${PROJECT}"
    exit 1
fi

echo -e "Using the latest ${PROJECT} build for version ${MINECRAFT_VERSION}"
BUILD_NUMBER=${LATEST_BUILD}

JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar

echo "Version being downloaded"
echo -e "MC Version: ${MINECRAFT_VERSION}"
echo -e "Build: ${BUILD_NUMBER}"
echo -e "JAR Name of Build: ${JAR_NAME}"

# Construir la URL de descarga
DOWNLOAD_URL=https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}

# Descargar el archivo JAR
curl -s ${DOWNLOAD_URL} --output /home/$username/server.jar

if [ $? -eq 0 ]; then
    echo "Download successful"
else
    echo "Error: Download failed. Please check your internet connection."
    exit 1
fi

su - $username
