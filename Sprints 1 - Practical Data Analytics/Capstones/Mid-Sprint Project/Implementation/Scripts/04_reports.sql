-- =====================================================================
-- Nexus Commerce Solutions: Business Intelligence & Data Cleanup
-- File    : 04_reports.sql
-- Target  : PostgreSQL 14+ (pgAdmin 4 or psql)
-- Requires: 03_schema_ddl.sql (tables) and the data loaded from
--           03b_seed_legacy_data.sql (or your own data).
-- Aliases : U = users, P = plans, I = invoices
-- Order   : Reports 1-4 are read-only. Report 5 (cleanup) changes data
--           and is deliberately last, so run it after reviewing 1-4.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. THREE-TABLE JOIN: who is billed, on which plan, and how much
--    INNER JOIN keeps only users that have a plan and at least one
--    invoice (50 rows with the legacy data).
-- ---------------------------------------------------------------------
SELECT
    U.username,
    P.plan_name,
    I.amount
FROM users U
INNER JOIN plans P
    ON U.plan_id = P.plan_id
INNER JOIN invoices I
    ON U.user_id = I.user_id
ORDER BY U.username, I.invoice_date;


-- ---------------------------------------------------------------------
-- 2. ORPHANED RECORDS: inactive users (never invoiced)
--    LEFT JOIN keeps every user; users with no matching invoice get
--    NULL invoice columns, which the WHERE clause isolates.
--    (Returns 0 rows with the legacy data, where every user has been
--    invoiced; see the optional demo user in 03b_seed_legacy_data.sql.)
-- ---------------------------------------------------------------------
SELECT
    U.user_id,
    U.username,
    U.email
FROM users U
LEFT JOIN invoices I
    ON U.user_id = I.user_id
WHERE I.invoice_id IS NULL
ORDER BY U.user_id;


-- ---------------------------------------------------------------------
-- 3. AGGREGATION: total revenue per plan, only plans above $1,000
--    WHERE filters rows before grouping; HAVING filters the groups.
--    (Expected with the legacy data: Enterprise 4,485.00 and
--    Growth 1,782.00; Starter 435.00 and Growht 99.00 are excluded.)
-- ---------------------------------------------------------------------
SELECT
    P.plan_name,
    SUM(I.amount) AS total_revenue
FROM plans P
INNER JOIN users U
    ON P.plan_id = U.plan_id
INNER JOIN invoices I
    ON U.user_id = I.user_id
GROUP BY
    P.plan_name
HAVING SUM(I.amount) > 1000
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- 4. TOP CUSTOMERS: the 5 highest-paying users
--    Standard ORDER BY ... DESC with LIMIT 5. The second sort column
--    (username) makes the result deterministic when totals tie.
-- ---------------------------------------------------------------------
SELECT
    U.user_id,
    U.username,
    SUM(I.amount) AS total_paid
FROM users U
INNER JOIN invoices I
    ON U.user_id = I.user_id
GROUP BY
    U.user_id,
    U.username
ORDER BY
    total_paid DESC,
    U.username ASC
LIMIT 5;


-- ---------------------------------------------------------------------
-- 5. DATA CLEANUP (targeted, single-row changes only)
--    Each statement is restricted to one specific id with a WHERE
--    clause. Preview with the SELECTs first, then run the changes.
-- ---------------------------------------------------------------------

-- 5a. Preview the rows that will change
SELECT plan_id, plan_name FROM plans WHERE plan_id = 4;                -- 'Growht'
SELECT invoice_id, invoice_number, user_id, amount
FROM invoices
WHERE invoice_id = 15;                                                 -- INV-9999, $0.00

-- 5b. Correct the spelling error in the plan name ('Growht' -> 'Growth')
UPDATE plans
SET plan_name = 'Growth'
WHERE plan_id = 4;

-- 5c. Remove the invalid test invoice INV-9999 (a $0.00 invoice
--     created by the "Test User" account)
DELETE FROM invoices
WHERE invoice_id = 15;
