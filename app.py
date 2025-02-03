from flask import Flask, render_template, request
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/command', methods=['POST'])
def command():
    if request.method == 'POST':
        cmd = request.form.get('command')
        process = os.popen(cmd)
        result = process.read()
        process.close()
        return render_template('index.html', result=result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
