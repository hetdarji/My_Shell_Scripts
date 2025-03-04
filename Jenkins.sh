#!/bin/bash

# Update and Upgrade the system
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Java (Jenkins Dependency)
echo "Installing Java (OpenJDK 17)..."
sudo apt install fontconfig openjdk-17-jre -y

# Verify Java installation
java -version

# Add Jenkins Repository & Import GPG Key
echo "Adding Jenkins repository..."
wget -O - https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update system again after adding Jenkins repo
echo "Updating package lists after adding Jenkins repository..."
sudo apt-get update

# Install Jenkins
echo "Installing Jenkins..."
sudo apt-get install jenkins -y

# Start and Enable Jenkins Service
echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins service status
echo "Checking Jenkins service status..."
sudo systemctl status jenkins --no-pager

# Open Firewall Port (if UFW is enabled)
echo "Configuring firewall to allow Jenkins on port 8080..."
sudo ufw allow 8080
sudo ufw enable
sudo ufw status

# Display initial admin password
echo "Jenkins installed successfully!"
echo "Access it at: http://your-server-ip:8080"
echo "Retrieve the initial admin password using:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
