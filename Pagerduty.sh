#!/bin/bash

# Exit script on error
set -e

echo "Updating package lists..."
sudo apt update -y

echo "Installing required dependencies..."
sudo apt install -y curl jq unzip

echo "Downloading PagerDuty CLI..."
curl -LO https://github.com/PagerDuty/pd-cli/releases/latest/download/pd-linux-amd64.tar.gz

echo "Extracting PagerDuty CLI..."
tar -xvzf pd-linux-amd64.tar.gz

echo "Moving pd to /usr/local/bin for global access..."
sudo mv pd /usr/local/bin/

echo "Cleaning up installation files..."
rm -f pd-linux-amd64.tar.gz

echo "PagerDuty CLI installed successfully!"
echo "Run 'pd login' to authenticate with your API key."
