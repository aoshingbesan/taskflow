import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from main_app import app

application = app

if __name__ == "__main__":
    application.run() 