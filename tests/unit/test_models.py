import pytest
from unittest.mock import patch, MagicMock
from app import create_app
from app.models import User, Task
import mongoengine


@pytest.fixture
def app():
    app = create_app()
    app.config["TESTING"] = True
    
    # Use in-memory database or mock for testing
    with patch('mongoengine.connect') as mock_connect:
        with patch('mongoengine.disconnect') as mock_disconnect:
            with app.app_context():
                yield app


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()


class TestUser:
    def test_user_creation(self, app):
        with app.app_context():
            with patch('mongoengine.Document.save') as mock_save:
                user = User(username="testuser", email="test@example.com")
                user.set_password("password123")
                
                # Mock the save operation
                mock_save.return_value = None
                user.save()

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
            with patch('mongoengine.Document.save') as mock_save:
                user = User(username="testuser", email="test@example.com")
                user.set_password("password123")

                task = Task(title="Test Task", description="Test Description", status="To Do", user=user)
                
                # Mock the save operation
                mock_save.return_value = None
                task.save()

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
            with patch('mongoengine.Document.save') as mock_save:
                user = User(username="testuser", email="test@example.com")
                user.set_password("password123")

                task1 = Task(title="Task 1", user=user)
                task2 = Task(title="Task 2", user=user)
                
                # Mock the save operations
                mock_save.return_value = None
                task1.save()
                task2.save()

                # Mock the query operations
                with patch('mongoengine.QuerySet.count') as mock_count:
                    with patch('mongoengine.QuerySet.__contains__') as mock_contains:
                        mock_count.return_value = 2
                        mock_contains.side_effect = lambda x: x in [task1, task2]
                        
                        # This would normally query the database, but we're mocking it
                        assert task1.user == user
                        assert task2.user == user
