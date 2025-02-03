#!/bin/bash

# Update system
apt update
apt upgrade -y

# Install dependencies
apt install -y nginx certbot python3-certbot-nginx

# Clone repository
git clone https://github.com/[username]/vps-manager.git
cd vps-manager

# Install manager script
chmod +x vpsmgr.sh
cp vpsmgr.sh /usr/local/bin/vpsmgr

echo "Installation complete!"
echo "You can now use 'vpsmgr' command to manage your websites"
