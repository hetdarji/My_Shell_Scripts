#!/bin/bash

# Exit script on any error
set -e

echo "Updating package lists..."
sudo apt update -y

echo "Installing required dependencies..."
sudo apt install -y openjdk-17-jdk wget unzip curl gnupg2

echo "Adding PostgreSQL repository..."
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "Installing PostgreSQL..."
sudo apt update -y
sudo apt install -y postgresql postgresql-contrib

echo "Starting PostgreSQL and enabling on boot..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "Creating PostgreSQL user and database for SonarQube..."
sudo -i -u postgres psql <<EOF
CREATE DATABASE sonarqube;
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
ALTER USER sonar WITH SUPERUSER;
EOF

echo "Downloading SonarQube..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip

echo "Extracting SonarQube..."
unzip sonarqube-10.4.1.88267.zip
sudo mv sonarqube-10.4.1.88267 /opt/sonarqube

echo "Creating SonarQube user..."
sudo useradd -m -d /opt/sonarqube sonar
sudo chown -R sonar:sonar /opt/sonarqube

echo "Configuring SonarQube to use PostgreSQL..."
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|' /opt/sonarqube/conf/sonar.properties

echo "Creating a systemd service for SonarQube..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF'

echo "Reloading systemd daemon and enabling SonarQube service..."
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "SonarQube installation completed!"
echo "Access SonarQube at: http://<your-server-ip>:9000"
echo "Default login: admin / admin"
