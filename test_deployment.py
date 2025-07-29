#!/usr/bin/env python3
"""
Test script to verify deployment configuration
"""

import os
import sys
import subprocess
import time

def test_local_deployment():
    """Test the application locally to ensure it works"""
    print("🧪 Testing local deployment configuration...")
    
    # Test 1: Check if all required files exist
    required_files = [
        'wsgi.py',
        'main_app.py',
        'requirements.txt',
        '.deployment',
        'web.config',
        'startup.txt'
    ]
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    if missing_files:
        print(f"❌ Missing required files: {missing_files}")
        return False
    else:
        print("✅ All required deployment files exist")
    
    # Test 2: Check if the application can be imported
    try:
        from main_app import app
        print("✅ Application imports successfully")
    except Exception as e:
        print(f"❌ Failed to import application: {e}")
        return False
    
    # Test 3: Check if health endpoint works
    try:
        with app.test_client() as client:
            response = client.get('/health')
            if response.status_code == 200:
                data = response.get_json()
                if data.get('status') == 'healthy':
                    print("✅ Health endpoint works correctly")
                else:
                    print(f"❌ Health endpoint returned unexpected data: {data}")
                    return False
            else:
                print(f"❌ Health endpoint returned status code: {response.status_code}")
                return False
    except Exception as e:
        print(f"❌ Failed to test health endpoint: {e}")
        return False
    
    # Test 4: Check if gunicorn can start (simulation)
    try:
        result = subprocess.run([
            'python', '-c', 
            'import gunicorn; print("Gunicorn available")'
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print("✅ Gunicorn is available")
        else:
            print(f"❌ Gunicorn test failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Failed to test gunicorn: {e}")
        return False
    
    print("🎉 All deployment tests passed!")
    return True

def test_environment_variables():
    """Test if required environment variables are documented"""
    print("\n🔧 Checking environment variables...")
    
    # Check if env.example exists and has required variables
    if os.path.exists('env.example'):
        with open('env.example', 'r') as f:
            content = f.read()
            required_vars = ['SECRET_KEY', 'MONGODB_URI', 'FLASK_ENV']
            missing_vars = []
            
            for var in required_vars:
                if var not in content:
                    missing_vars.append(var)
            
            if missing_vars:
                print(f"⚠️  Missing environment variables in env.example: {missing_vars}")
            else:
                print("✅ Environment variables are documented")
    else:
        print("❌ env.example file not found")

def main():
    """Run all deployment tests"""
    print("🚀 TaskFlow Deployment Configuration Test")
    print("=" * 50)
    
    success = test_local_deployment()
    test_environment_variables()
    
    if success:
        print("\n✅ Deployment configuration is ready!")
        print("\n📋 Next steps:")
        print("1. Configure Azure App Service with the required environment variables")
        print("2. Set up GitHub secrets for publish profiles")
        print("3. Push to main branch to trigger deployment")
        print("4. Monitor deployment in GitHub Actions")
    else:
        print("\n❌ Deployment configuration has issues that need to be fixed")
        sys.exit(1)

if __name__ == '__main__':
    main() 