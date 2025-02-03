#!/bin/bash
# Auto-installer V4 dengan dukungan domain/IP

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

function is_valid_ip {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

echo -e "${BOLD}${BLUE}=== VPS Control Panel Installer ===${NORMAL}"

# Setup wizard interaktif
read -p "Masukkan domain/IP server (contoh: panel.domain.com atau 123.123.123.123): " DOMAIN
read -p "Buat username admin: " ADMIN_USER
read -s -p "Buat password admin: " ADMIN_PASS
echo

# Validasi tipe input
is_valid_ip $DOMAIN
if [ $? -eq 0 ]; then
    USE_SSL=false
    echo -e "${BLUE}• Mode IP terdeteksi, SSL akan dinonaktifkan${NORMAL}"
else
    USE_SSL=true
    read -p "Masukkan email untuk notifikasi SSL (contoh: admin@domain.com): " SSL_EMAIL
fi

# Generate random port untuk security
PANEL_PORT=$(shuf -i 8000-9000 -n 1)

# Update system
echo -ne "${GREEN}▶ Memperbarui sistem..."
sudo apt update -qq > /dev/null 2>&1
sudo apt upgrade -qq -y > /dev/null 2>&1 &
show_spinner
echo -e "\b${GREEN}✓${NORMAL}"

# Install dependencies
echo -ne "${GREEN}▶ Menginstall dependencies..."
DEBIAN_FRONTEND=noninteractive sudo apt install -qq -y \
    python3 python3-pip python3-venv \
    nginx git ufw \
    docker.io docker-compose \
    certbot python3-certbot-nginx > /dev/null 2>&1 &
show_spinner
echo -e "\b${GREEN}✓${NORMAL}"

# Setup firewall
echo -ne "${GREEN}▶ Mengkonfigurasi firewall..."
sudo ufw allow 22,80,443/tcp > /dev/null 2>&1
sudo ufw --force enable > /dev/null 2>&1 &
show_spinner
echo -e "\b${GREEN}✓${NORMAL}"

# Setup environment
echo -ne "${GREEN}▶ Mengambil source code..."
git clone -q https://github.com/boybarley/BoyBarleyPanel.git > /dev/null 2>&1 &
show_spinner
cd BoyBarleyPanel
echo -e "\b${GREEN}✓${NORMAL}"

# Buat file konfigurasi
echo -ne "${GREEN}▶ Membuat konfigurasi..."
cat > .env <<EOF
DOMAIN=${DOMAIN}
PANEL_PORT=${PANEL_PORT}
ADMIN_USER=${ADMIN_USER}
ADMIN_PASS=${ADMIN_PASS}
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
API_SECRET=$(openssl rand -hex 24)
HOST=127.0.0.1
EOF
echo -e "\b${GREEN}✓${NORMAL}"

# Install Python requirements
echo -ne "${GREEN}▶ Menginstall Python packages..."
python3 -m venv venv > /dev/null 2>&1
source venv/bin/activate
pip install -q -r requirements.txt > /dev/null 2>&1 &
show_spinner
echo -e "\b${GREEN}✓${NORMAL}"

# Setup Nginx
echo -ne "${GREEN}▶ Setup reverse proxy..."
sudo tee /etc/nginx/sites-available/panel.conf > /dev/null <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${PANEL_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/panel.conf /etc/nginx/sites-enabled/
sudo nginx -t > /dev/null 2>&1 && sudo systemctl reload nginx > /dev/null 2>&1 &
show_spinner
echo -e "\b${GREEN}✓${NORMAL}"

# Setup SSL jika menggunakan domain
if [ "$USE_SSL" = true ]; then
    echo -ne "${GREEN}▶ Membuat SSL certificate..."
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL > /dev/null 2>&1 &
    show_spinner
    echo -e "\b${GREEN}✓${NORMAL}"
fi

# Finalisasi
echo -e "${BOLD}${GREEN}\n✔ Instalasi berhasil!${NORMAL}"
if [ "$USE_SSL" = true ]; then
    echo -e "Akses panel: ${BOLD}https://$DOMAIN${NORMAL}"
else
    echo -e "Akses panel: ${BOLD}http://$DOMAIN${NORMAL}"
fi
echo -e "Credential admin:"
echo -e "• Username: ${BOLD}${ADMIN_USER}${NORMAL}"
echo -e "• Password: ${BOLD}${ADMIN_PASS}${NORMAL}"

# Cleanup
cd ..
rm -rf BoyBarleyPanel/

# Jalankan service (sesuaikan dengan kebutuhan aplikasi)
# echo -e "\n${GREEN}▶ Menjalankan service panel...${NORMAL}"
# cd BoyBarleyPanel
# source venv/bin/activate
# gunicorn -b 127.0.0.1:$PANEL_PORT app:app > /dev/null 2>&1 &
