from flask import Flask, render_template, request, redirect, url_for
import os
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/setup', methods=['GET', 'POST'])
def setup():
    if request.method == 'POST':
        domain = request.form.get('domain')
        
        nginx_config = f"""
        server {{
            listen 80;
            server_name {domain};

            location / {{
                proxy_pass http://127.0.0.1:5000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }}
        }}
        """
        
        try:
            with open(f'/etc/nginx/sites-available/{domain}.conf', 'w') as f:
                f.write(nginx_config)

            subprocess.run(['ln', '-s', f'/etc/nginx/sites-available/{domain}.conf', f'/etc/nginx/sites-enabled/{domain}.conf'])
            subprocess.run(['nginx', '-t'])
            subprocess.run(['systemctl', 'reload', 'nginx'])
            subprocess.run(['certbot', '--nginx', '-d', domain, '--non-interactive', '--agree-tos', '-m', 'your_email@example.com'])

            return redirect(url_for('index'))
        except Exception as e:
            return str(e)

    return render_template('setup.html')

@app.route('/service', methods=['GET', 'POST'])
def service_management():
    if request.method == 'POST':
        service_name = request.form.get('service_name')
        action = request.form.get('action')

        try:
            subprocess.run(['systemctl', action, service_name])
            return redirect(url_for('service_management'))
        except Exception as e:
            return str(e)
    
    return render_template('service.html')

@app.route('/system_update', methods=['POST'])
def system_update():
    try:
        subprocess.run(['apt', 'update'])
        subprocess.run(['apt', '-y', 'upgrade'])
        return "System update and upgrade completed."
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
