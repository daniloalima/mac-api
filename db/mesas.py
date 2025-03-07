from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
Base = declarative_base()

class Mesa(Base):
    __tablename__ = 'mesas'
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    mestre = Column(String, nullable=False)
    descricao = Column(String, nullable=True)
    vagas = Column(Integer, nullable=False)
    sistema = Column(String, nullable=False)
    dia = Column(String, nullable=False)
    horario = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    sessoes_mes = Column(Integer, nullable=False)  # Nova coluna adicionada

def _format_return(mesa):
    return {
        "id": mesa.id,
        "name": mesa.name,
        "mestre": mesa.mestre,
        "sistema": mesa.sistema,
        "descricao": mesa.descricao,
        "dia": mesa.dia,
        "horario": mesa.horario,
        "vagas": mesa.vagas,
        "image_url": mesa.image_url,
        "sessoes_mes": mesa.sessoes_mes  # Incluir a nova coluna no retorno
    }

def _get_engine():
    return create_engine(DATABASE_URL)

def _create_database():
    engine = _get_engine()
    Base.metadata.create_all(engine)

def _get_session():
    engine = _get_engine()
    Session = sessionmaker(bind=engine)
    return Session()

def add_mesa(name, mestre, vagas, sistema, dia, horario, sessoes_mes, descricao=None, image_url=None):
    session = _get_session()
    nova_mesa = Mesa(name=name, mestre=mestre, vagas=vagas, sistema=sistema, descricao=descricao, dia=dia, horario=horario, image_url=image_url, sessoes_mes=sessoes_mes)
    session.add(nova_mesa)
    session.commit()
    session.refresh(nova_mesa)
    session.close()
    return _format_return(nova_mesa)

def get_todas_mesas():
    session = _get_session()
    mesas = session.query(Mesa).all()
    session.close()
    return [_format_return(mesa) for mesa in mesas]

def get_mesa_by_id(id):
    session = _get_session()
    mesa = session.query(Mesa).filter(Mesa.id == id).first()
    session.close()
    return _format_return(mesa) if mesa else None

def get_mesas_com_vagas():
    session = _get_session()
    mesas = session.query(Mesa).filter(Mesa.vagas > 0).all()
    session.close()
    return [_format_return(mesa) for mesa in mesas]

def remove_vaga_mesa(id):
    session = _get_session()
    mesa = session.query(Mesa).filter(Mesa.id == id).first()
    if mesa:
        mesa.vagas -= 1
        session.commit()
        session.refresh(mesa)
        session.close()
        return _format_return(mesa)
    session.close()
    return None

def adiciona_vaga_mesa(id):
    session = _get_session()
    mesa = session.query(Mesa).filter(Mesa.id == id).first()
    if mesa:
        mesa.vagas += 1
        session.commit()
        session.refresh(mesa)
        session.close()
        return _format_return(mesa)
    session.close()
    return None

def delete_mesa(id):
    session = _get_session()
    mesa = session.query(Mesa).filter(Mesa.id == id).first()
    if mesa:
        session.delete(mesa)
        session.commit()
        session.close()
        return {"status": 200, "message": "Mesa deletada com sucesso"}
    session.close()
    return {"status": 404, "message": "Mesa não encontrada"}

if __name__ == "__main__":
    _create_database()