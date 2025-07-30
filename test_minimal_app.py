#!/usr/bin/env python3

import os
import sys

# Set environment variable to skip MongoDB
os.environ["MONGODB_URI"] = "mongodb://localhost:27017/taskflow"

def test_minimal_app():
    """Test if the basic Flask app can start"""
    
    try:
        from app import create_app
        
        print("Creating Flask app...")
        app = create_app()
        print("✅ Flask app created successfully!")
        
        # Test basic routes
        with app.test_client() as client:
            response = client.get('/health')
            print(f"Health endpoint status: {response.status_code}")
            print(f"Health response: {response.get_json()}")
            
        return True
        
    except Exception as e:
        print(f"❌ Error creating Flask app: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_minimal_app()
    sys.exit(0 if success else 1) 