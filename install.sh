#!/bin/bash
# Auto-installer untuk VPS Control Panel

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3 python3-pip python3-venv nginx git ufw

# Setup firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# Clone repository
git clone https://github.com/boybarley/BoyBarleyPanel.git
cd vps-control

# Setup virtual environment
python3 -m venv venv
source venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Setup systemd service
sudo cp config/vps-control.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vps-control

# Setup Nginx
sudo cp config/nginx.conf /etc/nginx/sites-available/vps-control
sudo ln -s /etc/nginx/sites-available/vps-control /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# SSL Setup
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com

echo "Instalasi selesai! Akses panel di https://your-domain.com"
