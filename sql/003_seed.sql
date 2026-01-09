-- =========================
-- customers
-- =========================
INSERT INTO customers (name) VALUES
('김철수'),
('이영희'),
('박민수');

-- =========================
-- orders
-- =========================
INSERT INTO orders (
    order_code, customer_id, status,
    total_amount, shipping_fee, discount_amount, payable_amount,
    ordered_at, paid_at
) VALUES
('O20260101001', 1, 'PAID', 120000, 3000, 0, 123000, now() - interval '10 days', now() - interval '10 days'),
('O20260101002', 2, 'DELIVERED', 56000, 3000, 5000, 54000, now() - interval '20 days', now() - interval '20 days'),
('O20260101003', 3, 'PAID', 22000, 3000, 0, 25000, now() - interval '3 days', now() - interval '3 days');

-- =========================
-- order_items
-- =========================
INSERT INTO order_items (
    order_id, product_id, product_name, category_name,
    unit_price, quantity, line_amount, status
) VALUES
(1, 101, '키보드', '주변기기', 60000, 1, 60000, 'PAID'),
(1, 102, '마우스', '주변기기', 60000, 1, 60000, 'PAID'),
(2, 201, '티셔츠', '의류', 28000, 2, 56000, 'PAID'),
(3, 301, '텀블러', '생활', 22000, 1, 22000, 'PAID');

-- =========================
-- shipments
-- =========================
INSERT INTO shipments (
    order_id, status, courier, tracking_number,
    shipped_at, expected_delivery_at, delivered_at
) VALUES
(2, 'DELIVERED', 'CJ', '123-456',
 now() - interval '18 days',
 now() - interval '16 days',
 now() - interval '15 days');

-- =========================
-- rmas
-- =========================
INSERT INTO rmas (
    rma_code, order_id, customer_id,
    type, reason, status,
    requested_at, completed_at
) VALUES
('R20260101001', 2, 2, 'RETURN', '단순변심', 'COMPLETED',
 now() - interval '12 days',
 now() - interval '8 days');

-- =========================
-- rma_items
-- =========================
INSERT INTO rma_items (
    rma_id, order_item_id, quantity, refund_amount
) VALUES
(1, 3, 2, 56000);

-- =========================
-- refunds
-- =========================
INSERT INTO refunds (
    rma_id, amount, refunded_at
) VALUES
(1, 56000, now() - interval '8 days');
