#!/bin/bash

# Pastikan skrip dihentikan jika ada error
set -e

# Fungsi untuk memeriksa apakah sebuah perintah tersedia
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Periksa dan instal Docker jika belum tersedia
if ! command_exists docker; then
    echo "Docker tidak ditemukan. Menginstal Docker..."
    sudo apt-get update
    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release -y

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
else
    echo "Docker sudah terinstal."
fi

# Bangun Docker image
echo "Membangun Docker image untuk aplikasi..."
docker build -t boybarleypanel .

# Jalankan container
echo "Menjalankan container Docker untuk aplikasi..."
docker run -d -p 5000:5000 --name boybarleypanel boybarleypanel

echo "Aplikasi berjalan di container Docker. Akses melalui http://<server-ip>:5000"
