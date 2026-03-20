#!/bin/bash
set -e

APP_OS_USER=${APP_OS_USER:-appuser}
APP_OS_USER_HOME=${APP_OS_USER_HOME:-/home/$APP_OS_USER}
PROJECT_DIR=${PROJECT_DIR:-/opt/petclinic}

echo "=== Creating non-root user $APP_OS_USER ==="
if ! id -u "$APP_OS_USER" >/dev/null 2>&1; then
    useradd -m -d "$APP_OS_USER_HOME" -s /bin/bash "$APP_OS_USER"
fi

echo "=== Installing dependencies ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y openjdk-17-jdk git curl wget default-mysql-client net-tools

echo "=== Setting Environment Variables System-Wide ==="
cat <<EOF > /etc/profile.d/petclinic.sh
export DB_HOST=${DB_HOST}
export DB_PORT=${DB_PORT:-3306}
export DB_NAME=${DB_NAME}
export DB_USER=${DB_USER}
export DB_PASS=${DB_PASS}
EOF

echo "=== Cloning repository ==="
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    chown "$APP_OS_USER:$APP_OS_USER" "$PROJECT_DIR"
    sudo -u "$APP_OS_USER" git clone https://github.com/spring-projects/spring-petclinic.git "$PROJECT_DIR"
fi

echo "=== Building application ==="
cd "$PROJECT_DIR"
sudo -u "$APP_OS_USER" ./mvnw package

echo "=== Deploying application ==="
sudo -u "$APP_OS_USER" cp target/*.jar "$APP_DIR/petclinic.jar"

echo "=== Setting up Systemd Service ==="
cat <<EOF > /etc/systemd/system/petclinic.service
[Unit]
Description=Spring PetClinic
After=network.target

[Service]
User=$APP_OS_USER
WorkingDirectory=$APP_DIR
Environment="SPRING_PROFILES_ACTIVE=mysql"
Environment="SPRING_DATASOURCE_URL=jdbc:mysql://${DB_HOST}:${DB_PORT:-3306}/${DB_NAME}"
Environment="SPRING_DATASOURCE_USERNAME=${DB_USER}"
Environment="SPRING_DATASOURCE_PASSWORD=${DB_PASS}"
# Expose the native env vars for reference in app
Environment="DB_HOST=${DB_HOST}"
Environment="DB_PORT=${DB_PORT:-3306}"
Environment="DB_NAME=${DB_NAME}"
Environment="DB_USER=${DB_USER}"
Environment="DB_PASS=${DB_PASS}"
ExecStart=/usr/bin/java -jar $APP_DIR/petclinic.jar
SuccessExitStatus=143
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable petclinic
systemctl start petclinic

echo "=== APP_VM Provisioning Complete! ==="
