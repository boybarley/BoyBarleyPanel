import os
import shutil
from pathlib import Path

def list_files(path):
    try:
        path_obj = Path(path).resolve()
        if not path_obj.exists() or not path_obj.is_dir():
            return None
            
        return [{
            'name': f.name,
            'size': f.stat().st_size,
            'modified': f.stat().st_mtime,
            'is_dir': f.is_dir(),
            'path': str(f)
        } for f in path_obj.iterdir()]
    
    except Exception as e:
        return {"error": str(e)}

def file_action(action, path):
    try:
        path = Path(path).resolve()
        
        if action == 'delete':
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()
            return {"status": "success"}
            
        elif action == 'rename':
            new_name = request.form.get('new_name')
            new_path = path.parent / new_name
            path.rename(new_path)
            return {"status": "success"}
            
    except Exception as e:
        return {"status": "error", "message": str(e)}
