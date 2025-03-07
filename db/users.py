import os
from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import OperationalError
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Ensure the directory exists
os.makedirs(os.path.dirname(DATABASE_URL.split('///')[1]), exist_ok=True)

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, autoincrement=True)
    usuario = Column(String, nullable=False, unique=True)
    senha = Column(String, nullable=False)
    is_admin = Column(Boolean, default=False)

def _get_engine():
    return create_engine(DATABASE_URL)

def _create_database():
    engine = _get_engine()
    Base.metadata.create_all(engine)

def _get_session():
    engine = _get_engine()
    Session = sessionmaker(bind=engine)
    return Session()

def add_user(usuario, senha, is_admin=False):
    session = _get_session()
    novo_user = User(usuario=usuario, senha=senha, is_admin=is_admin)
    session.add(novo_user)
    session.commit()
    session.refresh(novo_user)
    session.close()
    return novo_user

def get_all_users():
    session = _get_session()
    users = session.query(User).all()
    session.close()
    return users

def get_user_by_id(user_id):
    session = _get_session()
    user = session.query(User).filter(User.id == user_id).first()
    session.close()
    return user

def delete_user(user_id):
    session = _get_session()
    user = session.query(User).filter(User.id == user_id).first()
    if user:
        session.delete(user)
        session.commit()
        session.close()
        return {"status": 200, "message": "User deleted successfully"}
    session.close()
    return {"status": 404, "message": "User not found"}

def check_user_login(usuario, senha):
    session = _get_session()
    user = session.query(User).filter(User.usuario == usuario, User.senha == senha).first()
    session.close()
    if user:
        return {"status": 200, "is_admin": user.is_admin}
    return {"status": 401, "message": "Invalid credentials"}

if __name__ == "__main__":
    _create_database()