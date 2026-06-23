#!/bin/bash
set -e

echo "=== Installing Docker & Git ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl gnupg git

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Setting up directory for Jenkins ==="
mkdir -p /var/jenkins_home

# Create Jenkins Groovy initialization script to automatically register credentials
mkdir -p /var/jenkins_home/init.groovy.d
cat << 'EOF' > /var/jenkins_home/init.groovy.d/credentials.groovy
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import hudson.util.Secret

def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// GitHub Credentials
def githubUsername = System.getenv("GITHUB_USER") ?: ""
def githubToken = System.getenv("GITHUB_TOKEN") ?: ""
if (githubUsername && githubToken) {
    def existing = store.getCredentials(domain).find { it.id == "github-credentials" }
    if (existing) {
        store.removeCredentials(domain, existing)
    }
    def githubCreds = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "github-credentials",
        "GitHub Username and Token",
        githubUsername,
        githubToken
    )
    store.addCredentials(domain, githubCreds)
    println "=== Jenkins Init: GitHub credentials updated successfully ==="
}

// Docker Hub Credentials
def dockerhubUsername = System.getenv("DOCKERHUB_USER") ?: ""
def dockerhubPassword = System.getenv("DOCKERHUB_PASSWORD") ?: ""
if (dockerhubUsername && dockerhubPassword) {
    def existing = store.getCredentials(domain).find { it.id == "dockerhub" }
    if (existing) {
        store.removeCredentials(domain, existing)
    }
    def dockerhubCreds = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "dockerhub",
        "Docker Hub Username and Password",
        dockerhubUsername,
        dockerhubPassword
    )
    store.addCredentials(domain, dockerhubCreds)
    println "=== Jenkins Init: Docker Hub credentials updated successfully ==="
}
EOF

# Set correct ownership (Jenkins runs as UID 1000 inside the container)
chown -R 1000:1000 /var/jenkins_home

# Allow vagrant user to run docker commands
usermod -aG docker vagrant

echo "=== Pre-installing required Jenkins plugins ==="
docker run --rm \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts \
  jenkins-plugin-cli --plugins "credentials credentials-binding git workflow-aggregator" --plugin-download-directory /var/jenkins_home/plugins

echo "=== Running Jenkins in Docker ==="
# Remove existing container if it exists to allow update of environment variables on reprovisioning
if docker ps -a --format '{{.Names}}' | grep -q '^jenkins$'; then
    echo "=== Recreating existing Jenkins container to apply new environment variables ==="
    docker rm -f jenkins
fi

J_SERVER_PORT=${J_SERVER_PORT:-4000}
docker run -d \
  --name jenkins \
  -p ${J_SERVER_PORT}:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/git:/var/git \
  -e GITHUB_USER="${GITHUB_USER}" \
  -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
  -e DOCKERHUB_USER="${DOCKERHUB_USER}" \
  -e DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD}" \
  --restart unless-stopped \
  jenkins/jenkins:lts

echo "=== Setting up local Git repository ==="
mkdir -p /var/git/nodejs-app.git
git init --bare /var/git/nodejs-app.git
chown -R 1000:1000 /var/git/nodejs-app.git

echo "=== Preparing temporary Git repository ==="
# Work in a temporary directory inside the VM to keep the host's synced folder clean
rm -rf /tmp/nodejs-app
mkdir -p /tmp/nodejs-app
# Copy files (excluding any hidden git files if they exist)
cp -r /opt/nodejs_stack/. /tmp/nodejs-app/
rm -rf /tmp/nodejs-app/.git

cd /tmp/nodejs-app
git init
git config --global user.email "vagrant@local"
git config --global user.name "Vagrant Provisioner"
git branch -M main
git add -A
git commit -m "Initial commit of Node.js app" || echo "Nothing to commit"

# Push to the local bare repo
git remote add local /var/git/nodejs-app.git
git push -f local main

# If remote GitHub repository URL is supplied, try to push to it
if [ -n "$GITHUB_REPO_URL" ]; then
    # Authenticate git command line by modifying the URL with user and token if they are set
    AUTH_REPO_URL="$GITHUB_REPO_URL"
    if [ -n "$GITHUB_USER" ] && [ -n "$GITHUB_TOKEN" ]; then
        PROTO=$(echo "$GITHUB_REPO_URL" | grep :// | sed -e's,^\(.*://\).*,\1,g')
        URL_NO_PROTO=$(echo "$GITHUB_REPO_URL" | sed -e"s,^$PROTO,,g")
        AUTH_REPO_URL="${PROTO}${GITHUB_USER}:${GITHUB_TOKEN}@${URL_NO_PROTO}"
    fi

    echo "=== Checking if code exists on remote repository ==="
    git remote add origin "$AUTH_REPO_URL"
    
    if git ls-remote --exit-code origin main >/dev/null 2>&1; then
        echo "=== Branch main already exists on remote repository. Skipping push to avoid overwriting. ==="
    else
        echo "=== Remote branch main does not exist. Pushing Node.js app code to remote... ==="
        git push -u origin main || echo "Warning: Could not push to remote repository. Check your token permissions."
    fi
fi

# Clean up the temporary workspace inside the VM
rm -rf /tmp/nodejs-app

echo "=== Waiting for Jenkins to generate Initial Admin Password ==="
while [ ! -f /var/jenkins_home/secrets/initialAdminPassword ]; do
    sleep 2
done

echo "=================================================="
echo "JENKINS INITIAL ADMIN PASSWORD:"
cat /var/jenkins_home/secrets/initialAdminPassword
echo "=================================================="
