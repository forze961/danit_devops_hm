#!/bin/bash
set -e

echo "=== Updating packages and installing MySQL ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mysql-server
apt-get install -y net-tools

echo "=== Configuring MySQL Network Access ==="
sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

echo "=== Restarting MySQL to apply network changes ==="
systemctl restart mysql

echo "=== Creating Database and Restricted User ==="
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${SUBNET}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${SUBNET}';
FLUSH PRIVILEGES;
EOF

echo "=== Database Provisioning Complete! ==="
