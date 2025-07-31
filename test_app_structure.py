#!/usr/bin/env python3
"""
Test script to verify application structure and dependencies
"""

import os
import sys

def test_file_structure():
    """Test that all required files exist"""
    required_files = [
        'main_app.py',
        'wsgi.py',
        'requirements.txt',
        'app/__init__.py',
        'app/routes/auth.py',
        'app/routes/main.py',
        'app/routes/tasks.py',
        'app/routes/api.py',
        'app/models.py'
    ]
    
    print("Testing file structure...")
    for file_path in required_files:
        if os.path.exists(file_path):
            print(f"✅ {file_path}")
        else:
            print(f"❌ {file_path} - MISSING")
            return False
    return True

def test_imports():
    """Test that the application can be imported"""
    try:
        print("\nTesting application imports...")
        
        # Add current directory to Python path
        sys.path.insert(0, os.path.dirname(__file__))
        
        # Test basic imports
        import flask
        print("✅ Flask imported")
        
        import mongoengine
        print("✅ MongoEngine imported")
        
        # Test application import
        from main_app import app
        print("✅ Application imported successfully")
        
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"❌ Application error: {e}")
        return False

def test_health_endpoint():
    """Test the health endpoint"""
    try:
        from main_app import app
        
        with app.test_client() as client:
            response = client.get('/health')
            print(f"✅ Health endpoint: {response.status_code}")
            return response.status_code == 200
            
    except Exception as e:
        print(f"❌ Health endpoint error: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Testing TaskFlow Application Structure")
    print("=" * 50)
    
    # Test file structure
    if not test_file_structure():
        print("\n❌ File structure test failed")
        return False
    
    # Test imports
    if not test_imports():
        print("\n❌ Import test failed")
        return False
    
    # Test health endpoint
    if not test_health_endpoint():
        print("\n❌ Health endpoint test failed")
        return False
    
    print("\n🎉 All tests passed!")
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 