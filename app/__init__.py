from flask import Flask
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)
app.config.from_pyfile('config.py')

# Rate Limiter Setup
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["500 per day", "100 per hour"]
)

# Import semua modul setelah inisialisasi app
from app import (
    routes,
    auth,
    services,
    monitoring,
    files,
    backup,
    security
)
