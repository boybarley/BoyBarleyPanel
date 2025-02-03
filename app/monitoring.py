import psutil
import time

def get_system_stats():
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    return {
        'cpu_percent': psutil.cpu_percent(),
        'mem_total': mem.total,
        'mem_used': mem.used,
        'mem_percent': mem.percent,
        'disk_total': disk.total,
        'disk_used': disk.used,
        'disk_percent': disk.percent,
        'uptime': int(time.time() - psutil.boot_time()),
        'timestamp': int(time.time() * 1000)
    }
