#!/usr/bin/env python3

import os
import sys
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError

def test_mongodb_connection():
    """Test MongoDB connection with the provided connection string"""
    
    # Get connection string from environment or use the one provided
    mongodb_uri = os.environ.get("MONGODB_URI", "mongodb+srv://aoshingbes:bWcxHfCJdXLSzOhg@taskflow.onmvorc.mongodb.net/taskflow?retryWrites=true&w=majority&appName=taskflow")
    
    print(f"Testing MongoDB connection...")
    print(f"Connection string: {mongodb_uri}")
    
    try:
        # Create client with timeout settings
        client = MongoClient(
            mongodb_uri,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=5000
        )
        
        # Test the connection
        client.admin.command('ping')
        print("✅ MongoDB connection successful!")
        
        # List databases
        databases = client.list_database_names()
        print(f"Available databases: {databases}")
        
        # Test creating a collection
        db = client.taskflow
        collection = db.test_collection
        result = collection.insert_one({"test": "connection", "timestamp": "2024-01-01"})
        print(f"✅ Test document inserted with ID: {result.inserted_id}")
        
        # Clean up test document
        collection.delete_one({"_id": result.inserted_id})
        print("✅ Test document cleaned up")
        
        client.close()
        return True
        
    except ConnectionFailure as e:
        print(f"❌ MongoDB connection failed: {e}")
        return False
    except ServerSelectionTimeoutError as e:
        print(f"❌ MongoDB server selection timeout: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    success = test_mongodb_connection()
    sys.exit(0 if success else 1) 