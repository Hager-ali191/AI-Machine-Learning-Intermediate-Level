-- =====================================================================
-- Nexus Commerce Solutions: SaaS Billing Schema (normalized)
-- File    : 03_schema_ddl.sql
-- Target  : PostgreSQL 14+ (pgAdmin 4 or psql)
-- Purpose : 1) Create the normalized tables Plans, Users and Invoices
--           2) Simulate a legacy-schema migration with ALTER TABLE
-- Design  : Plans (1) ---< Users (1) ---< Invoices
--           Every table has a SERIAL primary key; foreign keys link
--           users.plan_id -> plans.plan_id and
--           invoices.user_id -> users.user_id.
-- Run order: 03_schema_ddl.sql -> 03b_seed_legacy_data.sql (optional
--           sample data) -> 04_reports.sql
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Clean slate (re-runnable): drop in reverse dependency order
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS users    CASCADE;
DROP TABLE IF EXISTS plans    CASCADE;


-- ---------------------------------------------------------------------
-- 1. PLANS: one row per subscription plan (the price is stored once)
-- ---------------------------------------------------------------------
CREATE TABLE plans (
    plan_id       SERIAL         PRIMARY KEY,
    plan_name     VARCHAR(50)    NOT NULL,
    monthly_price NUMERIC(10, 2) NOT NULL CHECK (monthly_price >= 0)
);


-- ---------------------------------------------------------------------
-- 2. USERS: one row per subscriber, linked to their plan
--    legacy_notes is a deprecated free-text column carried over from the
--    old system; it is removed in the migration section below.
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id      SERIAL       PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    plan_id      INT          NOT NULL,
    legacy_notes TEXT,
    CONSTRAINT fk_users_plan
        FOREIGN KEY (plan_id) REFERENCES plans (plan_id)
);


-- ---------------------------------------------------------------------
-- 3. INVOICES: one row per invoice, linked to the user who was billed
--    invoice_number keeps the legacy identifier (e.g. INV-1001).
-- ---------------------------------------------------------------------
CREATE TABLE invoices (
    invoice_id     SERIAL         PRIMARY KEY,
    invoice_number VARCHAR(20)    NOT NULL UNIQUE,
    user_id        INT            NOT NULL,
    invoice_date   DATE           NOT NULL,
    amount         NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    CONSTRAINT fk_invoices_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- Indexes on foreign keys keep joins fast as the tables grow
CREATE INDEX idx_users_plan    ON users (plan_id);
CREATE INDEX idx_invoices_user ON invoices (user_id);


-- =====================================================================
-- SCHEMA MIGRATION (simulated) - ALTER TABLE statements
-- =====================================================================

-- 4a. Add a discount_code column to Invoices (optional for old rows)
ALTER TABLE invoices
    ADD COLUMN discount_code VARCHAR(30);

-- 4b. Increase the length of Users.username from 50 to 100 characters
ALTER TABLE users
    ALTER COLUMN username TYPE VARCHAR(100);

-- 4c. Drop the deprecated legacy_notes column from Users
ALTER TABLE users
    DROP COLUMN IF EXISTS legacy_notes;
