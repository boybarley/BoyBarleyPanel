import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-key-123')
    SQLITE_DB = os.getenv('SQLITE_DB', 'boybarleyPanel.db')
    BACKUP_DIR = os.getenv('BACKUP_DIR', '/backups')
    PANEL_PORT = int(os.getenv('PANEL_PORT', 8000))
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    
    # Security
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
