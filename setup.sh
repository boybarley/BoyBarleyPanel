#!/bin/bash

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install necessary packages
sudo apt install -y python3 python3-venv python3-pip git

# Clone the project repository
git clone https://your-repository-url/BoyBarleyPanel.git /opt/BoyBarleyPanel

# Navigate to the project directory
cd /opt/BoyBarleyPanel

# Set up the virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create systemd service file
sudo cp boybarleypanel.service /etc/systemd/system/

# Reload the systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Start and enable the BoyBarleyPanel service
sudo systemctl start boybarleypanel.service
sudo systemctl enable boybarleypanel.service

echo "BoyBarleyPanel installation and setup complete."
