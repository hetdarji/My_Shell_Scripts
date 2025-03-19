#!/bin/bash

# Exit script on error
set -e

echo "Updating package lists..."
sudo apt update -y

echo "Installing Grafana..."

# Add Grafana repository and install
sudo apt install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update -y
sudo apt install -y grafana

# Enable and start Grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Grafana installation complete!"
echo "Access it at: http://<your-server-ip>:3000"
echo "Default login: admin / admin"
