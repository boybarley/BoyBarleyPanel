import subprocess
import shlex

def service_action(service_name, action):
    valid_actions = ['start', 'stop', 'restart', 'status']
    if action not in valid_actions:
        return {"status": "error", "message": "Invalid action"}
    
    try:
        cmd = f"systemctl {action} {service_name}"
        result = subprocess.run(
            shlex.split(cmd),
            capture_output=True,
            text=True,
            timeout=10
        )
        return {
            "status": "success",
            "output": result.stdout,
            "error": result.stderr
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}
