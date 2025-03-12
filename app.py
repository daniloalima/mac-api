from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from db import mesas, users
from pydantic import BaseModel
import uvicorn

class Login(BaseModel):
    usuario: str
    senha: str

class Mesa(BaseModel):
    name: str
    mestre: str
    vagas: int
    sistema: str
    dia: str
    horario: str
    descricao: str = None
    image_url: str = None
    sessoes_mes: int
    mesa_especial: bool = False

class UpdateMesa(BaseModel):
    name: str = None
    mestre: str = None
    vagas: int = None
    sistema: str = None
    dia: str = None
    horario: str = None
    sessoes_mes: int = None
    descricao: str = None
    image_url: str = None
    mesa_especial: bool = None

tags_metadata = [
    {
        "name": "health_check",
        "description": "Health check endpoint",
    },
    {
        "name": "mesas",
        "description": "operações com mesas",
    },
    {
        "name": "users",
        "description": "operações com usuários",
    },
]

app = FastAPI()

origins = [
    "http://localhost:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["health_check"])
def health_check():
    return {"status": 200, "message": "OK"}

@app.post("/mesas", tags=["mesas"])
def criar_mesa(payload: Mesa):
    try:
        mesa = mesas.add_mesa(payload.name,
                              payload.mestre,
                              payload.vagas,
                              payload.sistema,
                              payload.dia,
                              payload.horario,
                              payload.sessoes_mes,
                              payload.descricao,
                              payload.image_url,
                              payload.mesa_especial
                              )
        return {"status": 201, "message": "Mesa criada com sucesso", "mesa": mesa}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.get("/mesas", tags=["mesas"])
def listar_mesas():
    try:
        mesas_list = mesas.get_todas_mesas()
        return {"status": 200, "mesas": mesas_list}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.get("/mesas/{id}", tags=["mesas"])
def listar_mesa_por_id(id: int):
    try:
        mesa = mesas.get_mesa_by_id(id)
        return {"status": 200, "mesa": mesa}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.get("/mesas_com_vagas", tags=["mesas"])
def listar_mesas_com_vagas():
    try:
        mesas_list = mesas.get_mesas_com_vagas()
        return {"status": 200, "mesas": mesas_list}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.post("/mesas/{id}/remove_vaga", tags=["mesas"])
def remove_vaga_mesa(id: int):
    try:
        mesa = mesas.remove_vaga_mesa(id)
        return {"status": 200, "message": "Vaga removida com sucesso", "mesa": mesa}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.post("/mesas/{id}/adiciona_vaga", tags=["mesas"])
def adiciona_vaga_mesa(id: int):
    try:
        mesa = mesas.adiciona_vaga_mesa(id)
        return {"status": 200, "message": "Vaga adicionada com sucesso", "mesa": mesa}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.post("/mesas/{id}", tags=["mesas"])
def editar_mesa(id: int, payload: UpdateMesa):
    updated_mesa = mesas.update_mesa(
        id=id,
        name=payload.name,
        mestre=payload.mestre,
        vagas=payload.vagas,
        sistema=payload.sistema,
        dia=payload.dia,
        horario=payload.horario,
        sessoes_mes=payload.sessoes_mes,
        descricao=payload.descricao,
        image_url=payload.image_url,
        mesa_especial=payload.mesa_especial
    )
    if updated_mesa is None:
        raise HTTPException(status_code=404, detail="Mesa não encontrada")
    return {"status": 200, "message": "Mesa atualizada com sucesso", "mesa": updated_mesa}

@app.delete("/mesas/{id}", tags=["mesas"])
def deletar_mesa(id: int):
    try:
        result = mesas.delete_mesa(id)
        return result
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.post("/login", tags=["users"])
def login(data: Login):
    usuario = data.usuario
    senha = data.senha
    result = users.check_user_login(usuario, senha)
    if result["status"] == 401:
        raise HTTPException(status_code=401, detail=result["message"])
    return result


@app.post("/users", tags=["users"])
def criar_usuario(usuario: str, senha: str, is_admin: bool = False):
    try:
        user = users.add_user(usuario, senha, is_admin)
        return {"status": 201, "message": "Usuário criado com sucesso", "user": user}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.get("/users", tags=["users"])
def listar_usuarios():
    try:
        users_list = users.get_all_users()
        return {"status": 200, "users": users_list}
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.get("/users/{id}", tags=["users"])
def listar_usuario_por_id(id: int):
    try:
        user = users.get_user_by_id(id)
        if user:
            return {"status": 200, "user": user}
        else:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
    except Exception as e:
        return {"status": 500, "message": str(e)}

@app.delete("/users/{id}", tags=["users"])
def deletar_usuario(id: int):
    try:
        result = users.delete_user(id)
        return result
    except Exception as e:
        return {"status": 500, "message": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)