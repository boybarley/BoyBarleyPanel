from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
from functools import wraps
from flask import session, redirect

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated

def create_user(username, password):
    conn = sqlite3.connect('boybarleypanel.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY,
                  username TEXT UNIQUE,
                  password TEXT)''')
    try:
        c.execute("INSERT INTO users (username, password) VALUES (?, ?)",
                  (username, generate_password_hash(password)))
        conn.commit()
    except sqlite3.IntegrityError:
        return False
    finally:
        conn.close()
    return True

def verify_user(username, password):
    conn = sqlite3.connect('boybarleyPanel.db')
    c = conn.cursor()
    c.execute("SELECT password FROM users WHERE username=?", (username,))
    result = c.fetchone()
    conn.close()
    
    if result and check_password_hash(result[0], password):
        return True
    return False
