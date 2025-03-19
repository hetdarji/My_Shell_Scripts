#!/bin/bash

# Exit on error
set -e

echo "Updating package lists..."
sudo apt update -y

# Installing Java (required by OWASP ZAP)
echo "Installing Java OpenJDK..."
sudo apt install -y openjdk-11-jdk

# Downloading OWASP ZAP
echo "Downloading OWASP ZAP..."
ZAP_VERSION="2.11.1"
wget https://github.com/zaproxy/zaproxy/releases/download/v${ZAP_VERSION}/ZAP_${ZAP_VERSION}_linux.tar.gz

# Extracting OWASP ZAP
echo "Extracting OWASP ZAP..."
tar -xvzf ZAP_${ZAP_VERSION}_linux.tar.gz

# Moving to /opt directory for easier access
echo "Moving OWASP ZAP to /opt..."
sudo mv ZAP_${ZAP_VERSION} /opt/owasp-zap

# Creating a symbolic link for easy execution
echo "Creating a symbolic link to execute ZAP from anywhere..."
sudo ln -s /opt/owasp-zap/zap.sh /usr/local/bin/zap

# Cleaning up installation files
echo "Cleaning up..."
rm -f ZAP_${ZAP_VERSION}_linux.tar.gz

# Setting up a systemd service for OWASP ZAP (optional)
echo "Creating a systemd service for OWASP ZAP..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/owasp-zap.service
[Unit]
Description=OWASP ZAP
After=network.target

[Service]
ExecStart=/opt/owasp-zap/zap.sh
User=$USER
Group=$USER
WorkingDirectory=/opt/owasp-zap
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to apply the changes
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start OWASP ZAP service (optional)
echo "Enabling OWASP ZAP service..."
sudo systemctl enable owasp-zap
sudo systemctl start owasp-zap

# Final Output
echo "OWASP ZAP installation complete!"
echo "You can now start ZAP using the 'zap' command."
