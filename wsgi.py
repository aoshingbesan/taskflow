import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from simple_test import app

application = app

if __name__ == "__main__":
    application.run() 