-- =====================================================================
-- CartGrid E-commerce: End-of-Month Executive Sales Report
-- File    : sales_report_queries.sql
-- Author  : Junior Database Analyst, CartGrid E-commerce
-- Requested by: Elena Rodriguez (Senior DBA) for the VP of Operations
-- =====================================================================
-- SETUP CONFIRMATION: setup is complete.
--   cartgrid_setup.sql was run in pgAdmin 4 and built the customers,
--   products and orders tables (SERIAL primary keys) with sample data:
--   20 customers, 15 products, 50 orders. Basic CRUD commands were
--   verified against all three tables (see Section 0).
--
-- Contents
--   0. Setup verification and CRUD check
--   1. First join        : customers + orders
--   2. Multi-table join  : + products
--   3. Filtering         : completed orders, Tech categories
--   4. Aggregation       : total sales per customer > $50  (CSV export)
--   5. Data quality check: orphan orders (LEFT JOIN)
--   6. Supporting counts : INNER JOIN vs LEFT JOIN comparison
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. SETUP VERIFICATION AND CRUD CHECK
-- ---------------------------------------------------------------------

-- Row counts (expected: customers 20, products 15, orders 50)
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;

-- CRUD smoke test. It runs inside a transaction that is rolled back, so
-- the sample data used in the report is left untouched.
BEGIN;

INSERT INTO customers (first_name, last_name, email, registration_date)
VALUES ('Test', 'User', 'test.user@example.com', CURRENT_DATE)
RETURNING id;                                                  -- Create

SELECT id, first_name, last_name, email
FROM customers
WHERE email = 'test.user@example.com';                         -- Read

UPDATE customers
SET last_name = 'Updated'
WHERE email = 'test.user@example.com';                         -- Update

DELETE FROM customers
WHERE email = 'test.user@example.com';                         -- Delete

ROLLBACK;


-- ---------------------------------------------------------------------
-- 1. FIRST JOIN: customers + orders (INNER JOIN, single-letter aliases)
--    Returns only orders that belong to an existing customer (47 rows).
-- ---------------------------------------------------------------------
SELECT
    C.first_name,
    C.last_name,
    O.id AS order_id,
    O.order_date,
    O.status
FROM customers C
INNER JOIN orders O
    ON C.id = O.customer_id
ORDER BY O.id;


-- ---------------------------------------------------------------------
-- 2. MULTI-TABLE JOIN: add products (alias P)
-- ---------------------------------------------------------------------
SELECT
    C.first_name,
    C.last_name,
    O.id AS order_id,
    O.status,
    P.product_name,
    P.category,
    P.price
FROM customers C
INNER JOIN orders O
    ON C.id = O.customer_id
INNER JOIN products P
    ON O.product_id = P.id
ORDER BY O.id;


-- ---------------------------------------------------------------------
-- 3. FILTERING: completed orders AND products whose category starts with
--    'Tech'. The status values are stored capitalised ('Completed'),
--    so the comparison uses that exact spelling.
-- ---------------------------------------------------------------------
SELECT
    C.first_name,
    C.last_name,
    O.id AS order_id,
    O.status,
    P.product_name,
    P.category,
    P.price
FROM customers C
INNER JOIN orders O
    ON C.id = O.customer_id
INNER JOIN products P
    ON O.product_id = P.id
WHERE O.status = 'Completed'
  AND P.category LIKE 'Tech%'
ORDER BY O.id;


-- ---------------------------------------------------------------------
-- 4. AGGREGATION: total sales per customer (> $50)
--    Result is exported to report_export.csv (18 customers).
-- ---------------------------------------------------------------------
-- [EXPORT QUERY START]
SELECT
    C.first_name,
    C.last_name,
    SUM(P.price) AS total_sales
FROM customers C
INNER JOIN orders O
    ON C.id = O.customer_id
INNER JOIN products P
    ON O.product_id = P.id
WHERE O.status = 'Completed'
  AND P.category LIKE 'Tech%'
GROUP BY
    C.first_name,
    C.last_name
HAVING SUM(P.price) > 50
ORDER BY total_sales DESC, C.last_name;
-- [EXPORT QUERY END]


-- ---------------------------------------------------------------------
-- 5. DATA QUALITY CHECK: orphan orders
--    LEFT JOIN from orders to customers; a NULL customer id on the right
--    side means the order points to a customer that does not exist.
--    Expected: 3 rows (orders 48, 49, 50).
-- ---------------------------------------------------------------------
SELECT
    O.id AS order_id,
    O.customer_id,
    O.product_id,
    O.status,
    O.order_date
FROM orders O
LEFT JOIN customers C
    ON O.customer_id = C.id
WHERE C.id IS NULL
ORDER BY O.id;


-- ---------------------------------------------------------------------
-- 6. SUPPORTING COUNTS: INNER JOIN vs LEFT JOIN (used in the VP email)
-- ---------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM orders)                       AS total_orders,
    (SELECT COUNT(*)
       FROM orders O
       INNER JOIN customers C ON O.customer_id = C.id)  AS rows_with_inner_join,
    (SELECT COUNT(*)
       FROM orders O
       LEFT JOIN customers C ON O.customer_id = C.id)   AS rows_with_left_join,
    (SELECT COUNT(*)
       FROM orders O
       LEFT JOIN customers C ON O.customer_id = C.id
       WHERE C.id IS NULL)                              AS orphan_orders;

-- Value of the orphan orders (all three are completed Tech purchases)
SELECT
    COUNT(*)     AS orphan_orders,
    SUM(P.price) AS orphan_revenue
FROM orders O
LEFT JOIN customers C
    ON O.customer_id = C.id
INNER JOIN products P
    ON O.product_id = P.id
WHERE C.id IS NULL
  AND O.status = 'Completed'
  AND P.category LIKE 'Tech%';
