import pytest
from app import create_app, db
from app.models import User, Task

@pytest.fixture
def app():
    app = create_app()
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def runner(app):
    return app.test_cli_runner()

class TestUser:
    def test_user_creation(self, app):
        with app.app_context():
            user = User(username='testuser', email='test@example.com')
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()
            
            assert user.id is not None
            assert user.username == 'testuser'
            assert user.email == 'test@example.com'
            assert user.check_password('password123')
            assert not user.check_password('wrongpassword')

    def test_user_repr(self, app):
        with app.app_context():
            user = User(username='testuser', email='test@example.com')
            assert repr(user) == '<User testuser>'

class TestTask:
    def test_task_creation(self, app):
        with app.app_context():
            user = User(username='testuser', email='test@example.com')
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()
            
            task = Task(
                title='Test Task',
                description='Test Description',
                status='To Do',
                user_id=user.id
            )
            db.session.add(task)
            db.session.commit()
            
            assert task.id is not None
            assert task.title == 'Test Task'
            assert task.description == 'Test Description'
            assert task.status == 'To Do'
            assert task.user_id == user.id

    def test_task_repr(self, app):
        with app.app_context():
            task = Task(title='Test Task')
            assert repr(task) == '<Task Test Task>'

    def test_task_user_relationship(self, app):
        with app.app_context():
            user = User(username='testuser', email='test@example.com')
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()
            
            task1 = Task(title='Task 1', user_id=user.id)
            task2 = Task(title='Task 2', user_id=user.id)
            db.session.add_all([task1, task2])
            db.session.commit()
            
            assert len(user.tasks.all()) == 2
            assert task1 in user.tasks.all()
            assert task2 in user.tasks.all() 