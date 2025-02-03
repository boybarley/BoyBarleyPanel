#!/bin/bash

# VPS Manager v0.1
# By [Your Name]

NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
WEB_DIR="/var/www"

function create_site() {
    local domain=$1
    local enable_ssl=$2
    
    # Create directory structure
    mkdir -p "${WEB_DIR}/${domain}/html"
    chown -R www-data:www-data "${WEB_DIR}/${domain}"
    chmod -R 755 "${WEB_DIR}/${domain}"
    
    # Create basic index.html
    cat > "${WEB_DIR}/${domain}/html/index.html" <<EOF
<html>
<head>
    <title>Welcome to ${domain}!</title>
</head>
<body>
    <h1>Success! The ${domain} site is working!</h1>
</body>
</html>
EOF

    # Create nginx config
    cat > "${NGINX_AVAILABLE}/${domain}" <<EOF
server {
    listen 80;
    listen [::]:80;

    root ${WEB_DIR}/${domain}/html;
    index index.html;

    server_name ${domain};

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    # Enable site
    ln -s "${NGINX_AVAILABLE}/${domain}" "${NGINX_ENABLED}/"
    systemctl reload nginx
    
    # SSL setup
    if [ "$enable_ssl" = "true" ]; then
        certbot --nginx -d ${domain}
        systemctl reload nginx
    fi
    
    echo "Site ${domain} created successfully!"
}

function delete_site() {
    local domain=$1
    
    # Remove nginx config
    rm -f "${NGINX_ENABLED}/${domain}"
    rm -f "${NGINX_AVAILABLE}/${domain}"
    
    # Remove web files
    rm -rf "${WEB_DIR}/${domain}"
    
    # Remove SSL certificate
    certbot delete --cert-name ${domain}
    
    systemctl reload nginx
    echo "Site ${domain} removed successfully!"
}

function list_sites() {
    echo "=== Enabled Sites ==="
    ls -l ${NGINX_ENABLED}
    echo -e "\n=== Available Sites ==="
    ls -l ${NGINX_AVAILABLE}
}

function show_help() {
    echo "VPS Manager Usage:"
    echo "  -a, --add [domain]       Add new website"
    echo "  -d, --delete [domain]    Delete website"
    echo "  -l, --list              List all websites"
    echo "  -s, --ssl               Enable SSL (use with --add)"
    echo "  -h, --help              Show this help"
}

# Main script
case $1 in
    -a|--add)
        if [ -z "$2" ]; then
            echo "Error: Please specify domain name"
            exit 1
        fi
        create_site $2 $4
        ;;
    -d|--delete)
        if [ -z "$2" ]; then
            echo "Error: Please specify domain name"
            exit 1
        fi
        delete_site $2
        ;;
    -l|--list)
        list_sites
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid option. Use -h for help."
        exit 1
        ;;
esac
