from flask import render_template, session, redirect, url_for, request, jsonify
from flask_socketio import SocketIO, emit
from app import app, limiter
from app.auth import login_required, verify_user
from app.services import service_action
from app.monitoring import get_system_stats
from app.files import list_files, file_action
from app.backup import create_backup
import os

socketio = SocketIO(app)

@app.route('/')
@login_required
def dashboard():
    return render_template('dashboard.html')

@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("10/minute")
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if verify_user(username, password):
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for('dashboard'))
        return "Invalid credentials", 401
    return render_template('login.html')

@app.route('/services', methods=['GET', 'POST'])
@login_required
def services():
    if request.method == 'POST':
        service = request.form['service']
        action = request.form['action']
        result = service_action(service, action)
        return jsonify({'result': result})
    return render_template('services.html')

@app.route('/file-manager')
@login_required
def file_manager():
    path = request.args.get('path', '/')
    files = list_files(path)
    return render_template('files.html', files=files, current_path=path)

@app.route('/api/system')
@login_required
def system_api():
    return jsonify(get_system_stats())

@socketio.on('connect')
def handle_connect():
    emit('system_update', get_system_stats())

if __name__ == '__main__':
    socketio.run(app)
