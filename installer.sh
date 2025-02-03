#!/bin/bash

# Check root
if [ "$EUID" -ne 0 ]
  then echo "Harap jalankan sebagai root"
  exit
fi

# Install dependencies
apt update
apt install -y php php-fpm php-curl php-zip php-mbstring php-xml php-cli unzip git

# Clone repo
git clone https://github.com/username/boybarleypanel.git /opt/boybarleypanel

# Permissions
chown -R www-data:www-data /opt/boybarleypanel/public
chmod -R 755 /opt/boybarleypanel

# Nginx config
cat > /etc/nginx/sites-available/boybarleypanel.conf <<EOL
server {
    listen 80;
    server_name panel.domainanda.com;
    
    root /opt/boybarleypanel/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOL

# Enable site
ln -s /etc/nginx/sites-available/boybarleypanel.conf /etc/nginx/sites-enabled/

# Create admin user
read -p "Masukkan username admin: " admin_user
read -sp "Masukkan password: " admin_pass
echo ""
hashed_pass=$(php -r "echo password_hash('$admin_pass', PASSWORD_DEFAULT);")

cat > /opt/boybarleypanel/config/users.php <<EOL
<?php
return [
    'admin' => [
        'password' => '$hashed_pass',
        'role' => 'admin'
    ]
];
EOL

systemctl restart nginx php8.2-fpm

echo "Instalasi selesai! Akses via http://panel.domainanda.com"
