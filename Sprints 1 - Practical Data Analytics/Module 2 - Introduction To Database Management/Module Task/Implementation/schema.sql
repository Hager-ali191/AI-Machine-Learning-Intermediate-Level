-- =====================================================================
-- AeroGlobal In-Flight E-Commerce: Normalized Schema (3NF) for PostgreSQL
-- =====================================================================
--
-- Why this design avoids isolated silos of data and supports scaling out
-- ---------------------------------------------------------------------
-- The sales team's flat spreadsheet repeated customer, product and
-- supplier details on every row, so each fact lived in many disconnected
-- copies. Here every fact is stored exactly once, in the table that owns
-- it (customers, suppliers, categories, products, orders, order_items),
-- and the tables are connected by primary/foreign keys. Any team or
-- application (sales, support, finance, supply chain) reads the same
-- single source of truth instead of keeping its own copy.
--
-- Every table has a compact, stable surrogate key (SERIAL integer) and
-- each table describes one entity only. This lays the groundwork for
-- horizontal scaling: tables can later be partitioned or sharded across
-- additional database server nodes (for example orders and order_items
-- by customer_id or order date, while the small reference tables such as
-- suppliers and categories are replicated to every node), because rows
-- find their relatives through keys rather than through duplicated text.
-- Note: foreign keys are enforced within one node, so a multi-node
-- layout would need to keep related rows together (same shard key).
--
-- How keys help keep transactions atomic (e.g. placing an order)
-- ---------------------------------------------------------------------
-- Placing an order touches several tables (orders + order_items). It
-- should be run inside one transaction:
--     BEGIN;
--       INSERT INTO orders (...) ...;
--       INSERT INTO order_items (...) ...;   -- one row per product
--     COMMIT;
-- Primary keys guarantee each order and each order line is uniquely
-- identified, so a retry cannot silently create a duplicate. Foreign
-- keys guarantee an order line can only point to an order and a product
-- that really exist, so a half-built order (items without an order, or
-- an order for an unknown customer) is rejected. If any statement
-- fails, PostgreSQL rolls the whole transaction back, so the order is
-- stored completely or not at all (all-or-nothing atomicity).
-- =====================================================================


-- ---------------------------------------------------------------------
-- Drop in reverse dependency order so the script can be re-run safely
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders      CASCADE;
DROP TABLE IF EXISTS products    CASCADE;
DROP TABLE IF EXISTS categories  CASCADE;
DROP TABLE IF EXISTS suppliers   CASCADE;
DROP TABLE IF EXISTS customers   CASCADE;


-- ---------------------------------------------------------------------
-- customers: one row per person who buys (name and email stored once)
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id    SERIAL       PRIMARY KEY,
    customer_name  VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- suppliers: one row per supplier (contact stored once)
-- ---------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id      SERIAL       PRIMARY KEY,
    supplier_name    VARCHAR(100) NOT NULL UNIQUE,
    supplier_contact VARCHAR(150) NOT NULL
);


-- ---------------------------------------------------------------------
-- categories: one row per product category
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    category_id   SERIAL      PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- products: one row per product, linked to its supplier and category
-- unit_price is the current catalogue price
-- ---------------------------------------------------------------------
CREATE TABLE products (
    product_id   SERIAL        PRIMARY KEY,
    product_code VARCHAR(20)   NOT NULL UNIQUE,          -- e.g. PROD-101
    product_name VARCHAR(150)  NOT NULL,
    unit_price   NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    category_id  INT           NOT NULL,
    supplier_id  INT           NOT NULL,
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories (category_id),
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);


-- ---------------------------------------------------------------------
-- orders: one row per order (who bought and when)
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    order_id     SERIAL      PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE,            -- e.g. ORD-5001
    order_date   DATE        NOT NULL,
    customer_id  INT         NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);


-- ---------------------------------------------------------------------
-- order_items: one row per product on an order (many-to-many link)
-- unit_price is the price actually charged at the time of purchase, so
-- later catalogue price changes never rewrite past orders.
-- The line total is quantity * unit_price and is calculated in queries
-- instead of being stored (the old TotalPrice column was derived data).
-- ---------------------------------------------------------------------
CREATE TABLE order_items (
    order_id   INT            NOT NULL,
    product_id INT            NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
);


-- ---------------------------------------------------------------------
-- Indexes on foreign keys to keep joins fast as data grows
-- ---------------------------------------------------------------------
CREATE INDEX idx_products_category   ON products (category_id);
CREATE INDEX idx_products_supplier   ON products (supplier_id);
CREATE INDEX idx_orders_customer     ON orders (customer_id);
CREATE INDEX idx_order_items_product ON order_items (product_id);
