from main_app import app

if __name__ == "__main__":
    import os
    port = int(os.environ.get('PORT', os.environ.get('WEBSITES_PORT', 5000)))
    app.run(host='0.0.0.0', port=port, debug=False) 