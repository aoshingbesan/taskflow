#!/usr/bin/env python3
"""
Simple test script to verify the application can start locally
"""

import sys
import os

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

try:
    print("Testing application import...")
    from main_app import app
    print("✅ Application imported successfully")
    
    print("Testing application startup...")
    # Test if the app can be created without errors
    with app.test_client() as client:
        response = client.get('/health')
        print(f"✅ Health check response: {response.status_code}")
        
    print("✅ Application test completed successfully")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure all dependencies are installed: pip install -r requirements.txt")
    sys.exit(1)
except Exception as e:
    print(f"❌ Application error: {e}")
    sys.exit(1) 