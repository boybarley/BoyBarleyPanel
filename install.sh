#!/bin/bash
# BoyBarleyPanel Auto-Installer (Revisi)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== BoyBarleyPanel Installation ===${NC}"

# User Input
read -p "Enter your domain name (e.g panel.yourdomain.com) atau kosongkan untuk menggunakan IP server: " DOMAIN
read -p "Create admin username: " ADMIN_USER
read -s -p "Create admin password: " ADMIN_PASS
echo

# Cek apakah menggunakan IP atau domain
if [ -z "$DOMAIN" ]; then
    echo "Menggunakan IP server..."
    DOMAIN=$(curl -s http://checkip.amazonaws.com)
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}Gagal mendapatkan IP publik. Mohon masukkan manual.${NC}"
        read -p "Masukkan IP server publik: " DOMAIN
    fi
    USE_IP=true
else
    USE_IP=false
fi

# System Update
echo -e "${GREEN}[1/6] Memperbarui sistem...${NC}"
sudo apt update -qq && sudo apt upgrade -y -qq

# Install Dependencies
echo -e "${GREEN}[2/6] Menginstal dependensi...${NC}"
sudo apt install -y -qq python3 python3-pip python3-venv nginx git ufw certbot curl

# Setup Firewall
echo -e "${GREEN}[3/6] Mengatur firewall...${NC}"
sudo ufw allow 22,80,443/tcp
sudo ufw --force enable

# Create App Directory
echo -e "${GREEN}[4/6] Menyiapkan aplikasi...${NC}"
git clone https://github.com/boybarley/BoyBarleyPanel.git
cd BoyBarleyPanel
python3 -m venv venv
source venv/bin/activate

# Install Python Packages
pip install -r requirements.txt > /dev/null

# Create Admin User
venv/bin/python3 -c "from app.auth import create_user; create_user('${ADMIN_USER}', '${ADMIN_PASS}')"

# Setup systemd service
echo -e "${GREEN}[5/6] Membuat systemd service...${NC}"

sudo tee /etc/systemd/system/panel.service > /dev/null <<EOL
[Unit]
Description=BoyBarleyPanel Service
After=network.target

[Service]
User=root
WorkingDirectory=$(pwd)
Environment="PATH=$(pwd)/venv/bin"
ExecStart=$(pwd)/venv/bin/gunicorn --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable panel.service
sudo systemctl start panel.service

# Configure Nginx
echo -e "${GREEN}[6/6] Mengatur Nginx...${NC}"

sudo rm -f /etc/nginx/sites-enabled/default

sudo tee /etc/nginx/sites-available/panel > /dev/null <<EOL
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo ln -sf /etc/nginx/sites-available/panel /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# SSL Setup jika menggunakan domain
if [ "$USE_IP" = false ]; then
    echo -e "${GREEN}Mengatur SSL...${NC}"
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
else
    echo -e "${YELLOW}Menggunakan IP tanpa SSL.${NC}"
fi

echo -e "\n${YELLOW}===========================================${NC}"
echo -e "${GREEN}Instalasi Selesai!${NC}"
if [ "$USE_IP" = false ]; then
    echo -e "Akses panel Anda: https://$DOMAIN"
else
    echo -e "Akses panel Anda: http://$DOMAIN"
fi
echo -e "Username: ${ADMIN_USER}"
echo -e "${YELLOW}===========================================${NC}"
