import tarfile
import datetime
import os

def create_backup(source_dir, backup_dir):
    try:
        timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        backup_name = f"backup-{timestamp}.tar.gz"
        backup_path = os.path.join(backup_dir, backup_name)
        
        with tarfile.open(backup_path, "w:gz") as tar:
            tar.add(source_dir, arcname=os.path.basename(source_dir))
            
        return {
            "status": "success",
            "path": backup_path,
            "size": os.path.getsize(backup_path)
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}
