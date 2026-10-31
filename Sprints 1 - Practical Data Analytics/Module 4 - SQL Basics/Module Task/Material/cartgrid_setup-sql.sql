-- ==============================================================================
-- CartGrid E-commerce Baseline Database Setup Script
-- ==============================================================================
-- WARNING: This script will drop existing tables if they exist.
-- Description: Creates baseline tables for customers, products, and orders using
-- the serial data type for IDs. Includes seeded data with intentional data 
-- anomalies (orphan records) for data quality analysis exercises.
-- ==============================================================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ------------------------------------------------------------------------------
-- 1. Create Tables
-- ------------------------------------------------------------------------------

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    -- INTENTIONAL DESIGN CHOICE: 
    -- Foreign key constraint omitted on customer_id to simulate a structural 
    -- data integrity issue, allowing for orphan records in production.
    customer_id INTEGER, 
    product_id INTEGER REFERENCES products(id),
    status VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL
);

-- ------------------------------------------------------------------------------
-- 2. Insert Data: Customers (20 rows)
-- Note: Customers 19 (Emily) and 20 (Michael) will have no orders.
-- ------------------------------------------------------------------------------

INSERT INTO customers (first_name, last_name, email, registration_date) VALUES
('Emma', 'Smith', 'emma.smith@example.com', '2023-01-15'),
('Liam', 'Johnson', 'liam.johnson@example.com', '2023-02-10'),
('Olivia', 'Williams', 'olivia.williams@example.com', '2023-02-28'),
('Noah', 'Brown', 'noah.brown@example.com', '2023-03-05'),
('Ava', 'Jones', 'ava.jones@example.com', '2023-03-12'),
('Elijah', 'Garcia', 'elijah.garcia@example.com', '2023-04-01'),
('Sophia', 'Martinez', 'sophia.martinez@example.com', '2023-04-18'),
('William', 'Rodriguez', 'william.rodriguez@example.com', '2023-05-02'),
('Isabella', 'Hernandez', 'isabella.hernandez@example.com', '2023-05-20'),
('James', 'Lopez', 'james.lopez@example.com', '2023-06-11'),
('Mia', 'Gonzalez', 'mia.gonzalez@example.com', '2023-06-25'),
('Benjamin', 'Wilson', 'benjamin.wilson@example.com', '2023-07-09'),
('Harper', 'Anderson', 'harper.anderson@example.com', '2023-07-30'),
('Lucas', 'Thomas', 'lucas.thomas@example.com', '2023-08-14'),
('Evelyn', 'Taylor', 'evelyn.taylor@example.com', '2023-08-21'),
('Henry', 'Moore', 'henry.moore@example.com', '2023-09-03'),
('Abigail', 'Jackson', 'abigail.jackson@example.com', '2023-09-15'),
('Alexander', 'Martin', 'alexander.martin@example.com', '2023-09-28'),
('Emily', 'Lee', 'emily.lee@example.com', '2023-10-05'),
('Michael', 'Perez', 'michael.perez@example.com', '2023-10-12');

-- ------------------------------------------------------------------------------
-- 3. Insert Data: Products (15 rows)
-- Note: Specific "Tech" prefixes are included for wildcard matching tasks.
-- ------------------------------------------------------------------------------

INSERT INTO products (product_name, category, price) VALUES
('ProBook X15', 'Tech - Laptops', 1250.00),
('SoundMax Headphones', 'Tech - Audio', 150.00),
('FitBand Pro', 'Tech - Wearables', 85.00),
('SmartHome Hub', 'Tech - Smart Home', 120.00),
('Wireless Mouse', 'Tech - Accessories', 25.00),
('Ergonomic Chair', 'Office Furniture', 200.00),
('Mechanical Keyboard', 'Tech - Accessories', 110.00),
('Yoga Mat', 'Fitness', 30.00),
('Running Shoes', 'Apparel', 90.00),
('Coffee Maker', 'Home Goods', 75.00),
('4K Monitor', 'Tech - Displays', 350.00),
('USB-C Hub', 'Tech - Accessories', 45.00),
('Desk Lamp', 'Office Accessories', 35.00),
('Gaming Console', 'Tech - Gaming', 450.00),
('Water Bottle', 'Fitness', 20.00);

-- ------------------------------------------------------------------------------
-- 4. Insert Data: Orders (50 rows)
-- Note: Includes 47 valid orders and 3 intentional orphan orders.
-- ------------------------------------------------------------------------------

INSERT INTO orders (customer_id, product_id, status, order_date) VALUES
-- Valid Orders (47 rows)
(1, 1, 'Completed', '2023-10-01'),
(2, 2, 'Completed', '2023-10-02'),
(3, 3, 'Completed', '2023-10-03'),
(4, 5, 'Completed', '2023-10-04'),
(4, 12, 'Completed', '2023-10-05'),
(5, 6, 'Completed', '2023-10-06'),
(6, 11, 'Processing', '2023-10-07'),
(7, 14, 'Completed', '2023-10-08'),
(8, 7, 'Completed', '2023-10-09'),
(9, 4, 'Cancelled', '2023-10-10'),
(10, 8, 'Completed', '2023-10-11'),
(11, 1, 'Completed', '2023-10-12'),
(12, 2, 'Completed', '2023-10-13'),
(13, 3, 'Processing', '2023-10-14'),
(14, 5, 'Completed', '2023-10-15'),
(15, 11, 'Completed', '2023-10-16'),
(16, 7, 'Completed', '2023-10-17'),
(17, 13, 'Completed', '2023-10-18'),
(18, 14, 'Completed', '2023-10-19'),
(1, 4, 'Completed', '2023-10-20'),
(2, 12, 'Completed', '2023-10-21'),
(3, 11, 'Cancelled', '2023-10-22'),
(4, 1, 'Completed', '2023-10-23'),
(5, 2, 'Processing', '2023-10-24'),
(6, 3, 'Completed', '2023-10-25'),
(7, 5, 'Completed', '2023-10-26'),
(8, 12, 'Completed', '2023-10-27'),
(9, 7, 'Completed', '2023-10-28'),
(10, 14, 'Completed', '2023-10-29'),
(11, 2, 'Completed', '2023-10-30'),
(12, 11, 'Completed', '2023-10-31'),
(13, 1, 'Completed', '2023-10-31'),
(14, 4, 'Completed', '2023-11-01'),
(15, 3, 'Processing', '2023-11-02'),
(16, 5, 'Completed', '2023-11-03'),
(17, 7, 'Completed', '2023-11-04'),
(18, 12, 'Cancelled', '2023-11-05'),
(1, 14, 'Completed', '2023-11-06'),
(2, 4, 'Completed', '2023-11-07'),
(3, 11, 'Completed', '2023-11-08'),
(4, 2, 'Completed', '2023-11-09'),
(5, 3, 'Completed', '2023-11-10'),
(6, 1, 'Completed', '2023-11-11'),
(7, 5, 'Processing', '2023-11-12'),
(8, 7, 'Completed', '2023-11-13'),
(9, 14, 'Completed', '2023-11-14'),
(10, 4, 'Completed', '2023-11-15'),

-- Orphan Records (3 rows)
-- These orders reference customer_ids that do not exist in the customers table.
(999, 11, 'Completed', '2023-11-16'),
(888, 2, 'Completed', '2023-11-17'),
(777, 14, 'Completed', '2023-11-18');

-- ==============================================================================
-- End of Setup Script
-- ==============================================================================