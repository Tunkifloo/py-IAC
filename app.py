from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/status')
def status():
    return jsonify({"status": "running", "service": "python-IAC"})

@app.route('/')
def hello():
    return jsonify({"message": "¡Hola! Proyecto Python con Docker y Jenkins"})

if __name__ == '__main__':
    debug_mode = os.environ.get('DEBUG_MODE', 'True') == 'True'
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)), debug=debug_mode)