from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "TaskFlow is running on Azure!",
        "status": "healthy",
        "environment": "production"
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "message": "TaskFlow is running!",
        "version": "1.0.0"
    })

@app.route('/api/v1/health')
def api_health():
    return jsonify({
        "service": "taskflow-api",
        "status": "healthy",
        "version": "1.0.0"
    })

@app.route('/test')
def test():
    return jsonify({
        "test": "success",
        "message": "Azure deployment is working!"
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False) 