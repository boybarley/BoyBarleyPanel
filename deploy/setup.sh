#!/bin/bash
# Basic setup script

echo "Installing dependencies..."
sudo apt update && sudo apt install -y python3-venv python3-dev libpq-dev

echo "Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "Installing Python packages..."
pip install -r /path/ke/BoyBarleyPanel/requirements.txt

echo "Setting up database..."
flask db init
flask db migrate
flask db upgrade

echo "Creating admin user..."
flask create-admin

echo "Installation completed!"
