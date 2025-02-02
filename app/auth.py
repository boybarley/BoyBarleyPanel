from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3

def create_user(username, password):
    conn = sqlite3.connect('boybarleypanel.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username TEXT UNIQUE,
                  password TEXT)''')
    
    hashed_pw = generate_password_hash(password)
    try:
        c.execute("INSERT INTO users (username, password) VALUES (?, ?)",
                  (username, hashed_pw))
        conn.commit()
    except sqlite3.IntegrityError:
        print("User already exists")
    finally:
        conn.close()

def verify_user(username, password):
    conn = sqlite3.connect('boybarleypanel.db')
    c = conn.cursor()
    c.execute("SELECT password FROM users WHERE username=?", (username,))
    result = c.fetchone()
    conn.close()
    
    if result and check_password_hash(result[0], password):
        return True
    return False
