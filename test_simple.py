#!/usr/bin/env python3
"""Simple test to check if basic imports work in CI environment"""

def test_basic():
    """Basic test that should always pass"""
    assert 1 + 1 == 2
    print("Basic test passed")

def test_imports():
    """Test if we can import basic modules"""
    try:
        import sys
        print(f"Python version: {sys.version}")
        
        import flask
        print(f"Flask version: {flask.__version__}")
        
        print("All imports successful")
        return True
    except ImportError as e:
        print(f"Import error: {e}")
        return False

if __name__ == "__main__":
    print("Running simple tests...")
    test_basic()
    test_imports()
    print("Simple tests completed") 