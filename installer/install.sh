#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting BoyBarleyPanel Installation...${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Function to check and install packages
install_package() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        echo -e "${YELLOW}Installing $1...${NC}"
        apt-get install -y $1 >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install $1${NC}"
            exit 1
        fi
    fi
}

# Update system
echo "Updating system packages..."
apt-get update >/dev/null 2>&1

# Install required packages
echo "Installing required packages..."
PACKAGES="nginx php7.4-fpm php7.4-mysql php7.4-json php7.4-mbstring php7.4-xml php7.4-curl mysql-server unzip git"
for package in $PACKAGES; do
    install_package $package
done

# Create MySQL database and user
echo "Setting up database..."
DB_NAME="boybarleypanel"
DB_USER="boybarley"
DB_PASS=$(openssl rand -base64 12)

# Check if MySQL is running
systemctl start mysql
if ! systemctl is-active --quiet mysql; then
    echo -e "${RED}MySQL service is not running${NC}"
    exit 1
fi

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

if [ $? -ne 0 ]; then
    echo -e "${RED}Database setup failed${NC}"
    exit 1
fi

# Create web directory
echo "Setting up web directory..."
INSTALL_DIR="/var/www/boybarleypanel"
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR

# Download and extract application files
echo "Downloading application files..."
cd /tmp
wget https://github.com/boybarley/BoyBarleyPanel/archive/main.zip -O boybarleypanel.zip >/dev/null 2>&1
unzip -q boybarleypanel.zip
cp -r BoyBarleyPanel-main/* $INSTALL_DIR/
rm -rf BoyBarleyPanel-main boybarleypanel.zip

# Configure nginx
echo "Configuring nginx..."
cat > /etc/nginx/sites-available/boybarleypanel << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/boybarleypanel/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site and remove default
ln -sf /etc/nginx/sites-available/boybarleypanel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Set permissions
echo "Setting permissions..."
chown -R www-data:www-data $INSTALL_DIR
chmod -R 755 $INSTALL_DIR

# Create configuration file
echo "Creating configuration file..."
CONFIG_FILE="$INSTALL_DIR/src/config/config.php"
cp $INSTALL_DIR/src/config/config.example.php $CONFIG_FILE

# Update configuration
sed -i "s/DB_HOST=.*/DB_HOST='localhost'/" $CONFIG_FILE
sed -i "s/DB_NAME=.*/DB_NAME='$DB_NAME'/" $CONFIG_FILE
sed -i "s/DB_USER=.*/DB_USER='$DB_USER'/" $CONFIG_FILE
sed -i "s/DB_PASS=.*/DB_PASS='$DB_PASS'/" $CONFIG_FILE

# Run database migrations
echo "Running database migrations..."
php $INSTALL_DIR/console migrate

# Setup cron jobs
echo "Setting up cron jobs..."
CRON_FILE="/etc/cron.d/boybarleypanel"
cat > $CRON_FILE << EOF
# BoyBarleyPanel cron jobs
0 0 * * * root php $INSTALL_DIR/console backup:database
0 1 * * * root php $INSTALL_DIR/console cleanup:logs
0 0 * * 0 root php $INSTALL_DIR/console backup:system
EOF
chmod 644 $CRON_FILE

# Restart services
echo "Restarting services..."
systemctl restart php7.4-fpm
systemctl restart nginx

# Create initial admin user
echo "Creating admin user..."
php $INSTALL_DIR/console create:admin

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}Panel URL: http://$SERVER_IP${NC}"
echo -e "${YELLOW}Default admin credentials:${NC}"
echo "Username: admin"
echo "Password: admin123"
echo -e "${RED}IMPORTANT: Please change the default password immediately!${NC}"

# Save installation details
echo -e "\nInstallation details have been saved to /root/boybarleypanel-install.txt"
cat > /root/boybarleypanel-install.txt << EOF
BoyBarleyPanel Installation Details
=================================
Installation Date: $(date)
Panel URL: http://$SERVER_IP
Database Name: $DB_NAME
Database User: $DB_USER
Database Password: $DB_PASS
Admin Username: admin
Admin Password: admin123 (CHANGE THIS!)
Installation Directory: $INSTALL_DIR
EOF

echo -e "${GREEN}Thank you for installing BoyBarleyPanel!${NC}"
