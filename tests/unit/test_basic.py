import pytest
from app import create_app

def test_app_creation():
    """Test that the app can be created without errors"""
    app = create_app()
    assert app is not None
    assert app.config['TESTING'] is False

def test_app_testing_config():
    """Test that the app can be configured for testing"""
    app = create_app()
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    assert app.config['TESTING'] is True 