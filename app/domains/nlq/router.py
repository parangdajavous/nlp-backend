from fastapi import APIRouter, Query
from sqlalchemy import text

from app.db.engine import engine

router = APIRouter(prefix="/nlq", tags=["nlq"])


@router.get("/debug/orders")
def debug_orders(limit: int = Query(20, ge=1, le=200)):
    sql = text("""
        SELECT *
        FROM v_order_items_analytics
        ORDER BY ordered_at DESC
        LIMIT :limit
    """)
    with engine.connect() as conn:
        rows = conn.execute(sql, {"limit": limit}).mappings().all()
    return {"items": rows}


@router.get("/debug/shipments")
def debug_shipments(limit: int = Query(20, ge=1, le=200)):
    sql = text("""
        SELECT *
        FROM v_shipments_analytics
        ORDER BY shipped_at DESC NULLS LAST
        LIMIT :limit
    """)
    with engine.connect() as conn:
        rows = conn.execute(sql, {"limit": limit}).mappings().all()
    return {"items": rows}


@router.get("/debug/rmas")
def debug_rmas(limit: int = Query(20, ge=1, le=200)):
    sql = text("""
        SELECT *
        FROM v_rmas_analytics
        ORDER BY requested_at DESC
        LIMIT :limit
    """)
    with engine.connect() as conn:
        rows = conn.execute(sql, {"limit": limit}).mappings().all()
    return {"items": rows}
