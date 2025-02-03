import jwt
from datetime import datetime, timedelta
from flask import current_app

def generate_token(user_id):
    payload = {
        'exp': datetime.utcnow() + timedelta(hours=3),
        'iat': datetime.utcnow(),
        'sub': user_id
    }
    return jwt.encode(
        payload,
        current_app.config['JWT_SECRET'],
        algorithm='HS256'
    )

def verify_token(token):
    try:
        payload = jwt.decode(
            token, 
            current_app.config['JWT_SECRET'],
            algorithms=['HS256']
        )
        return payload['sub']
    except:
        return None
