#!/bin/bash
# BoyBarleyPanel Auto-Installer

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== BoyBarleyPanel Installation ===${NC}"

# User Input
read -p "Enter your domain name (e.g panel.yourdomain.com): " DOMAIN
read -p "Create admin username: " ADMIN_USER
read -s -p "Create admin password: " ADMIN_PASS
echo

# System Update
echo -e "${GREEN}[1/5] Updating system...${NC}"
sudo apt update -qq && sudo apt upgrade -y -qq

# Install Dependencies
echo -e "${GREEN}[2/5] Installing dependencies...${NC}"
sudo apt install -y -qq python3 python3-pip python3-venv nginx git ufw certbot

# Setup Firewall
echo -e "${GREEN}[3/5] Configuring firewall...${NC}"
sudo ufw allow 22,80,443/tcp
sudo ufw --force enable

# Create App Directory
echo -e "${GREEN}[4/5] Setting up application...${NC}"
git clone https://github.com/boybarley/BoyBarleypanel.git
cd BoyBarleypanel
python3 -m venv venv
source venv/bin/activate

# Install Python Packages
pip install -r requirements.txt > /dev/null

# Create Admin User
venv/bin/python3 -c "from app.auth import create_user; create_user('${ADMIN_USER}', '${ADMIN_PASS}')"

# SSL Setup
echo -e "${GREEN}[5/5] Configuring SSL...${NC}"
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

echo -e "\n${YELLOW}===========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "Access your panel: https://$DOMAIN"
echo -e "Username: ${ADMIN_USER}"
echo -e "${YELLOW}===========================================${NC}"
