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

# Prompt for the username to run the service
read -p "Enter the username to run BoyBarleyPanel service: " username

# Create a copy of the service file with the entered username
cat <<EOL | sudo tee /etc/systemd/system/boybarleypanel.service
[Unit]
Description=BoyBarleyPanel Flask Application
After=network.target

[Service]
User=$username
WorkingDirectory=/opt/BoyBarleyPanel
Environment="PATH=/opt/BoyBarleyPanel/venv/bin"
ExecStart=/opt/BoyBarleyPanel/venv/bin/flask run --host=0.0.0.0

[Install]
WantedBy=multi-user.target
EOL

# Reload the systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Start and enable the BoyBarleyPanel service
sudo systemctl start boybarleypanel.service
sudo systemctl enable boybarleypanel.service

echo "BoyBarleyPanel installation and setup complete."
