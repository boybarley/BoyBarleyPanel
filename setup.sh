#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y python3 python3-venv python3-pip

# Navigate to the project directory
cd "$(dirname "$0")"

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the Flask app in the background
nohup flask run --host=0.0.0.0 --port=5000 &
