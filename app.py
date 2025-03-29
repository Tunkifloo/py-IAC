from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/status')
def status():
    return jsonify({"status": "running", "service": "python-demo"})

@app.route('/')
def hello():
    return jsonify({"message": "¡Hola! Proyecto Python con Docker y Jenkins"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
