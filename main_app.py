from app import create_app

app = create_app()

@app.route('/health')
def health():
    return {'status': 'healthy', 'message': 'TaskFlow is running!'}

if __name__ == '__main__':
    app.run(debug=True) 