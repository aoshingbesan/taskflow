from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Hello from TaskFlow!", "status": "running"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "message": "TaskFlow is running!"})

@app.route('/test')
def test():
    return jsonify({"test": "success", "message": "Basic Flask app is working!"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000) 