import os
from dotenv import load_dotenv

load_dotenv()
 
class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    MONGODB_SETTINGS = {
        'host': os.environ.get('MONGODB_URI') or 'mongodb+srv://aoshingbes:bWcxHfCJdXLSzOhg@taskflow.onmvorc.mongodb.net/?retryWrites=true&w=majority&appName=taskflow'
    } 