import os
from app import create_app

app = create_app()

if __name__ == '__main__':
    # Handle both Azure and local environments
    port = int(os.environ.get('PORT', os.environ.get('WEBSITES_PORT', 5000)))
    app.run(host='0.0.0.0', port=port, debug=False)