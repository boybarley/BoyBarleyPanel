#!/bin/bash

# Perbarui dan instal paket yang diperlukan
sudo apt update
sudo apt install -y python3 python3-venv python3-pip nginx

# Pindah ke direktori proyek (direktori tempat skrip ini berada)
cd "$(dirname "$0")"

# Membuat virtual environment
python3 -m venv venv

# Mengaktifkan virtual environment
source venv/bin/activate

# Memasang dependencies dari requirements.txt
pip install -r requirements.txt

# Set environment variable FLASK_APP agar flask tahu aplikasi mana yang dijalankan
export FLASK_APP=app.py

# Jalankan aplikasi Flask di latar belakang
nohup flask run --host=127.0.0.1 --port=5000 &

# Konfigurasi Nginx
sudo tee /etc/nginx/sites-available/boybarleypanel <<EOF
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Aktifkan konfigurasi Nginx
sudo ln -s /etc/nginx/sites-available/boybarleypanel /etc/nginx/sites-enabled

# Test konfigurasi Nginx
sudo nginx -t

# Restart Nginx untuk menerapkan perubahan
sudo systemctl restart nginx

echo "Setup selesai. Aplikasi berjalan dan diproksikan melalui Nginx."
