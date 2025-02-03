#!/bin/bash

# Perbarui dan instal paket yang diperlukan
sudo apt update
sudo apt install -y python3 python3-venv python3-pip

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
nohup flask run --host=0.0.0.0 --port=5000 &
