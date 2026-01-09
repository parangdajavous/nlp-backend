from fastapi import APIRouter

api_router = APIRouter()

# 다음 단계에서 여기다 도메인 라우터들을 include 할 예정
# 예)
# from app.domains.customers.router import router as customers_router
# api_router.include_router(customers_router, prefix="/customers", tags=["customers"])
