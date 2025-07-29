from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "message": "Simple TaskFlow test!"})

@app.route('/')
def index():
    return jsonify({"message": "TaskFlow is running!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000) 