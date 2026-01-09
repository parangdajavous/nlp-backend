from fastapi import FastAPI
from sqlalchemy import text

from app.api.router import api_router
from app.db.engine import engine

app = FastAPI(title="NLQ Backend")

app.include_router(api_router)

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/health/db")
def health_db():
    with engine.connect() as conn:
        v = conn.execute(text("select 1")).scalar_one()
    return {"db": "ok", "select_1": v}
