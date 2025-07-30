from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from TaskFlow Production!'

@app.route('/health')
def health():
    return {'message': 'TaskFlow is running!', 'status': 'healthy'}

if __name__ == '__main__':
    app.run(debug=True) 