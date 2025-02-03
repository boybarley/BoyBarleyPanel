// static/js/dashboard.js
const ctx = document.getElementById('usageChart').getContext('2d');
const chart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'CPU Usage',
            data: [],
            borderColor: '#3273dc',
            tension: 0.1
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: {
                beginAtZero: true,
                max: 100
            }
        }
    }
});

// Update chart dengan data real-time
socket.on('system_update', (data) => {
    const time = new Date(data.timestamp).toLocaleTimeString();
    
    chart.data.labels.push(time);
    chart.data.datasets[0].data.push(data.cpu_percent);
    
    if(chart.data.labels.length > 15) {
        chart.data.labels.shift();
        chart.data.datasets[0].data.shift();
    }
    
    chart.update();
});
