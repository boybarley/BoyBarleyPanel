#!/bin/bash
# Auto-installer V3 dengan setup wizard

# Konfigurasi awal
NORMAL="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"

function show_spinner {
    local pid=$!
    local delay=0.25
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo -e "${BOLD}${BLUE}=== VPS Control Panel Installer ===${NORMAL}"

# Setup wizard interaktif
read -p "Masukkan domain Anda (contoh: panel.domain.com): " DOMAIN
read -p "Buat username admin: " ADMIN_USER
read -s -p "Buat password admin: " ADMIN_PASS
echo

# Generate random port untuk security
PANEL_PORT=$(shuf -i 8000-9000 -n 1)

# Update system
echo -e "${GREEN}▶ Memperbarui sistem...${NORMAL}"
sudo apt update && sudo apt upgrade -y > /dev/null 2>&1 &

# Install dependencies
echo -e "${GREEN}▶ Menginstall dependencies...${NORMAL}"
sudo apt install -y python3 python3-pip python3-venv nginx git ufw docker.io docker-compose certbot > /dev/null 2>&1 &

# Setup firewall
echo -e "${GREEN}▶ Mengkonfigurasi firewall...${NORMAL}"
sudo ufw allow 22,80,443,${PANEL_PORT}/tcp > /dev/null 2>&1
sudo ufw --force enable > /dev/null 2>&1

# Setup environment
echo -e "${GREEN}▶ Menyiapkan environment...${NORMAL}"
git clone https://github.com/boybarley/BoyBarleyPanel.git > /dev/null 2>&1
cd vps-control

# Buat file konfigurasi otomatis
cat > .env <<EOF
DOMAIN=${DOMAIN}
PANEL_PORT=${PANEL_PORT}
ADMIN_USER=${ADMIN_USER}
ADMIN_PASS=${ADMIN_PASS}
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
API_SECRET=$(openssl rand -hex 24)
EOF

# Install Python requirements
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt > /dev/null 2>&1 &

# Setup SSL otomatis
echo -e "${GREEN}▶ Membuat SSL certificate...${NORMAL}"
sudo certbot certonly --nginx -d ${DOMAIN} --non-interactive --agree-tos -m admin@${DOMAIN} > /dev/null 2>&1

# Selesai
echo -e "${BOLD}${GREEN}✔ Instalasi berhasil!${NORMAL}"
echo -e "Akses panel di: https://${DOMAIN}"
echo -e "Port admin: ${PANEL_PORT}"
