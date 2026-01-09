-- =========================================================
-- 주문 상태
-- =========================================================
CREATE TYPE order_status_enum AS ENUM (
    'PLACED',      -- 주문 생성
    'PAID',        -- 결제 완료
    'SHIPPED',     -- 배송 시작
    'DELIVERED',   -- 배송 완료
    'COMPLETED',   -- 주문 완료
    'CANCELLED'    -- 주문 취소
);

-- =========================================================
-- 주문 상품(라인) 상태
-- =========================================================
CREATE TYPE order_item_status_enum AS ENUM (
    'PLACED',
    'PAID',
    'CANCELLED',
    'RETURNED'
);

-- =========================================================
-- 배송 상태
-- =========================================================
CREATE TYPE shipment_status_enum AS ENUM (
    'READY',
    'SHIPPED',
    'IN_TRANSIT',
    'DELIVERED'
);

-- =========================================================
-- RMA 타입 (취소/반품/교환)
-- =========================================================
CREATE TYPE rma_type_enum AS ENUM (
    'CANCEL',
    'RETURN',
    'EXCHANGE'
);

-- =========================================================
-- RMA 상태
-- =========================================================
CREATE TYPE rma_status_enum AS ENUM (
    'REQUESTED',
    'APPROVED',
    'IN_PROGRESS',
    'COMPLETED',
    'REJECTED'
);



CREATE TABLE customers (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(80) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE INDEX idx_customers_name
    ON customers (name);


CREATE TABLE orders (
    id              BIGSERIAL PRIMARY KEY,
    order_code      VARCHAR(30) NOT NULL UNIQUE,

    customer_id     BIGINT NOT NULL
        REFERENCES customers(id),

    status          order_status_enum NOT NULL,

    total_amount    NUMERIC(12,2) NOT NULL,
    shipping_fee    NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    payable_amount  NUMERIC(12,2) NOT NULL,

    ordered_at      TIMESTAMP NOT NULL DEFAULT now(),
    paid_at         TIMESTAMP NULL,
    completed_at    TIMESTAMP NULL,
    cancelled_at    TIMESTAMP NULL
);

CREATE INDEX idx_orders_customer_id
    ON orders (customer_id);

CREATE INDEX idx_orders_status
    ON orders (status);

CREATE INDEX idx_orders_ordered_at
    ON orders (ordered_at);


CREATE TABLE order_items (
    id              BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL
        REFERENCES orders(id) ON DELETE CASCADE,

    product_id      BIGINT NOT NULL,
    product_name    VARCHAR(255) NOT NULL,
    category_name   VARCHAR(100) NOT NULL,

    unit_price      NUMERIC(12,2) NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    line_amount     NUMERIC(12,2) NOT NULL,

    status          order_item_status_enum NOT NULL
);

CREATE INDEX idx_order_items_order_id
    ON order_items (order_id);

CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);

CREATE INDEX idx_order_items_category_name
    ON order_items (category_name);

CREATE INDEX idx_order_items_status
    ON order_items (status);


CREATE TABLE shipments (
    id                    BIGSERIAL PRIMARY KEY,
    order_id              BIGINT NOT NULL
        REFERENCES orders(id) ON DELETE CASCADE,

    status                shipment_status_enum NOT NULL,
    courier               VARCHAR(50) NOT NULL,
    tracking_number       VARCHAR(50) NULL,

    shipped_at            TIMESTAMP NULL,
    expected_delivery_at  TIMESTAMP NULL,
    delivered_at          TIMESTAMP NULL
);

CREATE INDEX idx_shipments_order_id
    ON shipments (order_id);

CREATE INDEX idx_shipments_status
    ON shipments (status);

CREATE INDEX idx_shipments_courier
    ON shipments (courier);

CREATE INDEX idx_shipments_shipped_at
    ON shipments (shipped_at);

CREATE INDEX idx_shipments_delivered_at
    ON shipments (delivered_at);


CREATE TABLE rmas (
    id            BIGSERIAL PRIMARY KEY,
    rma_code      VARCHAR(30) NOT NULL UNIQUE,

    order_id      BIGINT NOT NULL
        REFERENCES orders(id) ON DELETE CASCADE,

    customer_id   BIGINT NOT NULL
        REFERENCES customers(id),

    type          rma_type_enum NOT NULL,
    reason        VARCHAR(100) NOT NULL,
    status        rma_status_enum NOT NULL,

    requested_at  TIMESTAMP NOT NULL DEFAULT now(),
    completed_at  TIMESTAMP NULL
);

CREATE INDEX idx_rmas_order_id
    ON rmas (order_id);

CREATE INDEX idx_rmas_customer_id
    ON rmas (customer_id);

CREATE INDEX idx_rmas_type
    ON rmas (type);

CREATE INDEX idx_rmas_reason
    ON rmas (reason);

CREATE INDEX idx_rmas_status
    ON rmas (status);

CREATE INDEX idx_rmas_requested_at
    ON rmas (requested_at);



CREATE TABLE rma_items (
    id            BIGSERIAL PRIMARY KEY,
    rma_id        BIGINT NOT NULL
        REFERENCES rmas(id) ON DELETE CASCADE,

    order_item_id BIGINT NOT NULL
        REFERENCES order_items(id),

    quantity      INT NOT NULL CHECK (quantity > 0),
    refund_amount NUMERIC(12,2) NULL
);

CREATE INDEX idx_rma_items_rma_id
    ON rma_items (rma_id);

CREATE INDEX idx_rma_items_order_item_id
    ON rma_items (order_item_id);


CREATE TABLE refunds (
    id          BIGSERIAL PRIMARY KEY,
    rma_id      BIGINT NOT NULL UNIQUE
        REFERENCES rmas(id) ON DELETE CASCADE,

    amount      NUMERIC(12,2) NOT NULL,
    refunded_at TIMESTAMP NULL
);

CREATE INDEX idx_refunds_refunded_at
    ON refunds (refunded_at);