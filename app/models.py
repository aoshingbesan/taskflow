from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from mongoengine import Document, StringField, DateTimeField, ReferenceField, ObjectIdField
from bson import ObjectId
from app import db, login_manager


@login_manager.user_loader
def load_user(id):
    try:
        return User.objects(id=ObjectId(id)).first()
    except:
        return None


class User(UserMixin, Document):
    meta = {"collection": "users"}

    username = StringField(max_length=64, unique=True, required=True)
    email = StringField(max_length=120, unique=True, required=True)
    password_hash = StringField(max_length=128)
    created_at = DateTimeField(default=datetime.utcnow)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def __repr__(self):
        return f"<User {self.username}>"


class Task(Document):
    meta = {"collection": "tasks"}
    title = StringField(max_length=100, required=True)
    description = StringField()
    status = StringField(max_length=20, default="To Do")  # To Do, In Progress, Completed
    created_at = DateTimeField(default=datetime.utcnow)
    updated_at = DateTimeField(default=datetime.utcnow)
    user = ReferenceField(User, required=True)

    def __repr__(self):
        return f"<Task {self.title}>"
