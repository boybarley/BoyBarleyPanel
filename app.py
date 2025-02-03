from flask import Flask, render_template, request
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/update_app', methods=['POST'])
def update_app():
    try:
        # Pull the latest changes from the main branch
        subprocess.run(['git', 'pull', 'origin', 'main'], check=True)
        # Restart the Flask application service
        subprocess.run(['sudo', 'systemctl', 'restart', 'boybarleypanel.service'], check=True)
        return "Application updated successfully."
    except subprocess.CalledProcessError as e:
        return f"Error updating application: {e}"

if __name__ == '__main__':
    app.run(host='0.0.0.0')
