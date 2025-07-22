import pytest
from app import create_app
from app.models import User, Task
import mongoengine


@pytest.fixture
def app():
    app = create_app()
    app.config["TESTING"] = True
    app.config["MONGODB_SETTINGS"] = {"host": "mongodb://localhost:27017/taskflow_test"}

    with app.app_context():
        # Clear test database
        mongoengine.disconnect()
        mongoengine.connect(db="taskflow_test", host="mongodb://localhost:27017/taskflow_test")
        yield app
        # Clean up
        User.objects.delete()
        Task.objects.delete()
        mongoengine.disconnect()


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()


class TestUser:
    def test_user_creation(self, app):
        with app.app_context():
            user = User(username="testuser", email="test@example.com")
            user.set_password("password123")
            user.save()

            assert user.id is not None
            assert user.username == "testuser"
            assert user.email == "test@example.com"
            assert user.check_password("password123")
            assert not user.check_password("wrongpassword")

    def test_user_repr(self, app):
        with app.app_context():
            user = User(username="testuser", email="test@example.com")
            assert repr(user) == "<User testuser>"


class TestTask:
    def test_task_creation(self, app):
        with app.app_context():
            user = User(username="testuser", email="test@example.com")
            user.set_password("password123")
            user.save()

            task = Task(title="Test Task", description="Test Description", status="To Do", user=user)
            task.save()

            assert task.id is not None
            assert task.title == "Test Task"
            assert task.description == "Test Description"
            assert task.status == "To Do"
            assert task.user == user

    def test_task_repr(self, app):
        with app.app_context():
            task = Task(title="Test Task")
            assert repr(task) == "<Task Test Task>"

    def test_task_user_relationship(self, app):
        with app.app_context():
            user = User(username="testuser", email="test@example.com")
            user.set_password("password123")
            user.save()

            task1 = Task(title="Task 1", user=user)
            task2 = Task(title="Task 2", user=user)
            task1.save()
            task2.save()

            user_tasks = Task.objects(user=user)
            assert user_tasks.count() == 2
            assert task1 in user_tasks
            assert task2 in user_tasks
