from flask import Blueprint, render_template
from app.core.auth.decorators import admin_required

servers_bp = Blueprint('servers', __name__)

@servers_bp.route('/servers')
@admin_required
def server_list():
    # Logic untuk ambil data server
    return render_template('admin/servers.html')
