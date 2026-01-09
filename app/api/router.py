from fastapi import APIRouter

from app.domains.nlq.router import router as nlq_router

api_router = APIRouter()
api_router.include_router(nlq_router)
