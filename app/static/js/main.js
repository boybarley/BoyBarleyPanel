// Global Socket.io Connection
const socket = io();

// Handle system stats updates
socket.on('system_update', (data) => {
    if(document.getElementById('cpu-usage')) {
        document.getElementById('cpu-usage').textContent = `${data.cpu_percent}%`;
        document.getElementById('memory-usage').textContent = `${data.mem_percent}%`;
        document.getElementById('disk-usage').textContent = `${data.disk_percent}%`;
    }
});

// Handle form submissions
document.querySelectorAll('form[data-ajax]').forEach(form => {
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(form);
        const response = await fetch(form.action, {
            method: form.method,
            body: formData
        });
        
        const result = await response.json();
        // Handle response
    });
});
