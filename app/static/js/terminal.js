document.addEventListener('DOMContentLoaded', () => {
    const terminalContainer = document.getElementById('terminal-container');
    const term = new Terminal({
        cursorBlink: true,
        theme: {
            background: '#1a1a1a',
            foreground: '#ffffff'
        }
    });

    term.open(terminalContainer);
    
    const socket = io('/terminal');
    
    term.onData(data => {
        socket.emit('input', data);
    });

    socket.on('output', data => {
        term.write(data);
    });
});
