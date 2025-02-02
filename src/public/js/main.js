document.addEventListener('DOMContentLoaded', function() {
    // Sidebar Toggle
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');

    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('active');
            mainContent.classList.toggle('expanded');
        });
    }

    // Quick Actions
    const actionButtons = document.querySelectorAll('.action-btn');
    actionButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const action = this.dataset.action;
            try {
                const response = await fetch(`/api/actions/${action}`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    }
                });
                
                const data = await response.json();
                if (data.success) {
                    showNotification('Success', data.message, 'success');
                } else {
                    showNotification('Error', data.message, 'error');
                }
            } catch (error) {
                showNotification('Error', 'An error occurred', 'error');
            }
        });
    });

    // Notification System
    function showNotification(title, message, type) {
        const notification = document.createElement('div');
        notification.classList.add('notification', `notification-${type}`);
        notification.innerHTML = `
            <h4>${title}</h4>
            <p>${message}</p>
        `;
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    // Real-time Updates
    function updateSystemStats() {
        fetch('/api/stats')
            .then(response => response.json())
            .then(data => {
                document.querySelector('.cpu-usage').textContent = data.cpu;
                document.querySelector('.memory-usage').textContent = data.memory;
                document.querySelector('.disk-usage').textContent = data.disk;
            })
            .catch(error => console.error('Error updating stats:', error));
    }

    // Update stats every 30 seconds
    setInterval(updateSystemStats, 30000);
});
