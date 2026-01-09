-- =========================================================
-- 주문 + 주문상품 분석 VIEW
-- =========================================================
CREATE OR REPLACE VIEW v_order_items_analytics AS
SELECT
    o.id                AS order_id,
    o.order_code        AS order_code,
    o.ordered_at        AS ordered_at,
    o.status            AS order_status,

    o.customer_id       AS customer_id,
    c.name              AS customer_name,

    oi.product_id       AS product_id,
    oi.product_name     AS product_name,
    oi.category_name    AS category_name,

    oi.quantity         AS quantity,
    oi.unit_price       AS unit_price,
    oi.line_amount      AS line_amount,

    o.payable_amount    AS payable_amount
FROM orders o
JOIN order_items oi
    ON oi.order_id = o.id
JOIN customers c
    ON c.id = o.customer_id;


-- =========================================================
-- 배송 분석 VIEW
-- =========================================================
CREATE OR REPLACE VIEW v_shipments_analytics AS
SELECT
    s.id                    AS shipment_id,

    o.id                    AS order_id,
    o.order_code            AS order_code,
    o.ordered_at            AS ordered_at,

    o.customer_id           AS customer_id,
    c.name                  AS customer_name,

    s.courier               AS courier,
    s.status                AS shipment_status,

    s.shipped_at            AS shipped_at,
    s.expected_delivery_at  AS expected_delivery_at,
    s.delivered_at          AS delivered_at,

    /* 배송 소요시간 (시간 단위) */
    CASE
        WHEN s.shipped_at IS NOT NULL
         AND s.delivered_at IS NOT NULL
        THEN FLOOR(EXTRACT(EPOCH FROM (s.delivered_at - s.shipped_at)) / 3600)::int
        ELSE NULL
    END AS delivery_hours,

    /* 배송 지연 여부 */
    CASE
        WHEN s.delivered_at IS NOT NULL
         AND s.expected_delivery_at IS NOT NULL
        THEN (s.delivered_at > s.expected_delivery_at)
        ELSE FALSE
    END AS is_delayed
FROM shipments s
JOIN orders o
    ON o.id = s.order_id
JOIN customers c
    ON c.id = o.customer_id;


-- =========================================================
-- RMA(취소/반품/교환) 분석 VIEW
-- =========================================================
CREATE OR REPLACE VIEW v_rmas_analytics AS
SELECT
    r.id                AS rma_id,
    r.rma_code          AS rma_code,

    o.id                AS order_id,
    o.order_code        AS order_code,

    o.customer_id       AS customer_id,
    c.name              AS customer_name,

    r.type              AS rma_type,
    r.reason            AS rma_reason,
    r.status            AS rma_status,

    r.requested_at      AS requested_at,
    r.completed_at      AS completed_at,

    /* 환불금액: refunds 우선, 없으면 rma_items 합계 */
    COALESCE(ref.amount, ri.refund_amount_sum) AS refund_amount
FROM rmas r
JOIN orders o
    ON o.id = r.order_id
JOIN customers c
    ON c.id = r.customer_id

LEFT JOIN refunds ref
    ON ref.rma_id = r.id

LEFT JOIN (
    SELECT
        rma_id,
        SUM(COALESCE(refund_amount, 0)) AS refund_amount_sum
    FROM rma_items
    GROUP BY rma_id
) ri
    ON ri.rma_id = r.id;
