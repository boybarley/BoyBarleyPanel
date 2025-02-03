from flask import Flask, render_template, redirect, url_for
import docker

app = Flask(__name__)
client = docker.from_env()

@app.route('/')
def index():
    containers = client.containers.list()
    return render_template('index.html', containers=containers)

@app.route('/deploy')
def deploy():
    try:
        # Hentikan semua container yang menjalankan image 'boybarleypanel'
        for container in client.containers.list(filters={"ancestor": "boybarleypanel"}):
            container.stop()

        # Bangun ulang image
        client.images.build(path='.', tag='boybarleypanel')

        # Jalankan container baru
        client.containers.run('boybarleypanel', detach=True, ports={'5000/tcp': 5000})

        return redirect(url_for('index'))
    except Exception as e:
        return f"Deployment Error: {str(e)}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
