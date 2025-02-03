from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    app.config.from_pyfile('../config.py')
    app.config.from_envvar('APP_SETTINGS')
    
    # Inisialisasi ekstensi
    db.init_app(app)
    migrate.init_app(app, db)
    
    # Registrasi blueprint
    from .routes.admin import admin_bp
    from .routes.user import user_bp
    
    app.register_blueprint(admin_bp, url_prefix='/admin')
    app.register_blueprint(user_bp, url_prefix='/user')
    
    return app
