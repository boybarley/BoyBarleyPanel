#!/bin/bash

echo "Installing BoyBarleyPanel..."

# Check system requirements
if ! command -v php &> /dev/null; then
    echo "PHP is required but not installed."
    exit 1
fi

# Install dependencies
apt-get update
apt-get install -y nginx php-fpm php-mysql mysql-server

# Clone repository
git clone https://github.com/yourusername/BoyBarleyPanel.git /var/www/boybarleypanel

# Set permissions
chown -R www-data:www-data /var/www/boybarleypanel
chmod -R 755 /var/www/boybarleypanel

# Configure nginx
cat > /etc/nginx/sites-available/boybarleypanel << EOF
server {
    listen 80;
    server_name _;
    root /var/www/boybarleypanel/public;

    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
}
EOF

ln -s /etc/nginx/sites-available/boybarleypanel /etc/nginx/sites-enabled/

# Restart services
systemctl restart nginx
systemctl restart php7.4-fpm

echo "Installation completed!"
