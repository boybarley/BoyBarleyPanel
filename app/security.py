from flask_wtf.csrf import CSRFProtect
from app import app

csrf = CSRFProtect(app)

def sanitize_input(input_str):
    # Prevent command injection
    forbidden_chars = [';', '&', '|', '$', '`']
    return ''.join([c for c in input_str if c not in forbidden_chars])

def validate_path(user_path):
    # Prevent path traversal
    base_dir = Path('/').resolve()
    requested_path = Path(user_path).resolve()
    
    if base_dir in requested_path.parents:
        return requested_path
    return None
