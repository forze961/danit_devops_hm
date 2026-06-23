#!/bin/bash
set -e

echo "=== Creating non-root user appuser ==="
if ! id -u "appuser" >/dev/null 2>&1; then
    useradd -m -d /home/appuser -s /bin/bash appuser
fi

echo "=== Installing Java, Git & Docker Dependencies ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl gnupg git openjdk-21-jdk net-tools

# Trust all directories globally to prevent git ownership verification issues
git config --system --add safe.directory '*'

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure permissions for docker socket
usermod -aG docker appuser
usermod -aG docker vagrant

echo "=== Setting up Jenkins Agent Directory ==="
mkdir -p /home/appuser/jenkins
chown -R appuser:appuser /home/appuser/jenkins
touch /home/appuser/jenkins/secret
chown appuser:appuser /home/appuser/jenkins/secret
chmod 600 /home/appuser/jenkins/secret

echo "=== Creating run-jenkins-agent.sh wrapper script ==="
cat << 'EOF' > /usr/local/bin/run-jenkins-agent.sh
#!/bin/bash
# Wait for the Jenkins server container to start and serve agent.jar
while ! curl -s -f http://10.0.2.2:4000/jnlpJars/agent.jar -o /home/appuser/jenkins/agent.jar; do
    echo "Waiting for Jenkins server at http://10.0.2.2:4000 to start..."
    sleep 10
done

chown appuser:appuser /home/appuser/jenkins/agent.jar

SECRET_FILE="/home/appuser/jenkins/secret"
if [ ! -f "$SECRET_FILE" ] || [ -z "$(cat $SECRET_FILE)" ]; then
    echo "ERROR: Please write the Jenkins agent secret key into $SECRET_FILE."
    echo "The agent will retry automatically when the secret is provided."
    exit 1
fi

AGENT_SECRET=$(cat "$SECRET_FILE")
echo "Starting Jenkins agent..."
java -jar /home/appuser/jenkins/agent.jar \
  -url http://10.0.2.2:4000/ \
  -secret "$AGENT_SECRET" \
  -name worker \
  -workDir "/home/appuser/jenkins"
EOF

chmod +x /usr/local/bin/run-jenkins-agent.sh

echo "=== Registering Jenkins Agent as a systemd service ==="
cat << 'EOF' > /etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent Service
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/jenkins
ExecStart=/usr/local/bin/run-jenkins-agent.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jenkins-agent.service
systemctl start jenkins-agent.service

echo "=== Worker VM Provisioning Complete! ==="
echo "Note: The Jenkins Agent service has been started but is waiting for you to save your agent secret key to /home/appuser/jenkins/secret."
