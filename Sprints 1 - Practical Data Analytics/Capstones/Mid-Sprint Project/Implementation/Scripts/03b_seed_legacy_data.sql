-- =====================================================================
-- 03b_seed_legacy_data.sql  (OPTIONAL helper)
-- Loads the 50 rows of legacy_subscriptions.csv into the normalized
-- tables created by 03_schema_ddl.sql: 4 plans, 11 users, 50 invoices.
-- Data is loaded exactly as it appears in the legacy file, including
-- its quality problems (the misspelled plan 'Growht', the 'Test User'
-- account and the $0.00 test invoice), which 04_reports.sql then fixes.
-- Insert order is fixed so the generated SERIAL ids are deterministic:
--   plans: 1 Starter, 2 Growth, 3 Enterprise, 4 Growht
--   invoices: invoice_id = legacy record_id (INV-9999 -> invoice_id 15)
-- =====================================================================

BEGIN;

-- Plans (name and price stored once)
INSERT INTO plans (plan_name, monthly_price) VALUES
    ('Starter', 29.00),
    ('Growth', 99.00),
    ('Enterprise', 299.00),
    ('Growht', 99.00);

-- Users (one row per distinct email, linked to their plan)
INSERT INTO users (username, email, plan_id)
SELECT v.username, v.email, P.plan_id
FROM (VALUES
    ('Liam O''Connor', 'liam.o@nexuscorp.com', 'Growth'),
    ('Emma Swan', 'eswan@storybrooke.com', 'Starter'),
    ('Noah Torres', 'noah.t@devworks.net', 'Enterprise'),
    ('Olivia Baker', 'olivia.baker@designhub.co', 'Starter'),
    ('William Clark', 'wclark@logistics.com', 'Enterprise'),
    ('Sophia Martinez', 'smartinez@retailpro.com', 'Growth'),
    ('James White', 'james.w@financeplus.com', 'Growth'),
    ('Isabella Lee', 'ilee@marketinggurus.com', 'Starter'),
    ('Test User', 'test@nexuscommerce.com', 'Growht'),
    ('Benjamin Harris', 'bharris@datasync.io', 'Enterprise'),
    ('Mia Robinson', 'mrobinson@cloudscale.com', 'Growth')
) AS v (username, email, plan_name)
INNER JOIN plans P ON P.plan_name = v.plan_name
ORDER BY array_position(ARRAY['liam.o@nexuscorp.com','eswan@storybrooke.com','noah.t@devworks.net','olivia.baker@designhub.co','wclark@logistics.com','smartinez@retailpro.com','james.w@financeplus.com','ilee@marketinggurus.com','test@nexuscommerce.com','bharris@datasync.io','mrobinson@cloudscale.com'], v.email);

-- Invoices (inserted in legacy record order)
INSERT INTO invoices (invoice_number, user_id, invoice_date, amount)
SELECT v.invoice_number, U.user_id, v.invoice_date::DATE, v.amount
FROM (VALUES
    (1, 'INV-1001', 'liam.o@nexuscorp.com', '2023-01-01', 99.00),
    (2, 'INV-1002', 'eswan@storybrooke.com', '2023-01-03', 29.00),
    (3, 'INV-1003', 'noah.t@devworks.net', '2023-01-05', 299.00),
    (4, 'INV-1004', 'olivia.baker@designhub.co', '2023-01-05', 29.00),
    (5, 'INV-1005', 'wclark@logistics.com', '2023-01-10', 299.00),
    (6, 'INV-1006', 'smartinez@retailpro.com', '2023-01-12', 99.00),
    (7, 'INV-1041', 'liam.o@nexuscorp.com', '2023-02-01', 99.00),
    (8, 'INV-1042', 'eswan@storybrooke.com', '2023-02-03', 29.00),
    (9, 'INV-1043', 'noah.t@devworks.net', '2023-02-05', 299.00),
    (10, 'INV-1044', 'olivia.baker@designhub.co', '2023-02-05', 29.00),
    (11, 'INV-1045', 'wclark@logistics.com', '2023-02-10', 299.00),
    (12, 'INV-1046', 'smartinez@retailpro.com', '2023-02-12', 99.00),
    (13, 'INV-1050', 'james.w@financeplus.com', '2023-02-15', 99.00),
    (14, 'INV-1051', 'ilee@marketinggurus.com', '2023-02-18', 29.00),
    (15, 'INV-9999', 'test@nexuscommerce.com', '2023-02-20', 0.00),
    (16, 'INV-1081', 'liam.o@nexuscorp.com', '2023-03-01', 99.00),
    (17, 'INV-1082', 'eswan@storybrooke.com', '2023-03-03', 29.00),
    (18, 'INV-1083', 'noah.t@devworks.net', '2023-03-05', 299.00),
    (19, 'INV-1084', 'olivia.baker@designhub.co', '2023-03-05', 29.00),
    (20, 'INV-1085', 'wclark@logistics.com', '2023-03-10', 299.00),
    (21, 'INV-1086', 'smartinez@retailpro.com', '2023-03-12', 99.00),
    (22, 'INV-1090', 'james.w@financeplus.com', '2023-03-15', 99.00),
    (23, 'INV-1091', 'ilee@marketinggurus.com', '2023-03-18', 29.00),
    (24, 'INV-1095', 'bharris@datasync.io', '2023-03-20', 299.00),
    (25, 'INV-1096', 'mrobinson@cloudscale.com', '2023-03-22', 99.00),
    (26, 'INV-1121', 'liam.o@nexuscorp.com', '2023-04-01', 99.00),
    (27, 'INV-1122', 'eswan@storybrooke.com', '2023-04-03', 29.00),
    (28, 'INV-1123', 'noah.t@devworks.net', '2023-04-05', 299.00),
    (29, 'INV-1124', 'olivia.baker@designhub.co', '2023-04-05', 29.00),
    (30, 'INV-1125', 'wclark@logistics.com', '2023-04-10', 299.00),
    (31, 'INV-1126', 'smartinez@retailpro.com', '2023-04-12', 99.00),
    (32, 'INV-1130', 'james.w@financeplus.com', '2023-04-15', 99.00),
    (33, 'INV-1131', 'ilee@marketinggurus.com', '2023-04-18', 29.00),
    (34, 'INV-1135', 'bharris@datasync.io', '2023-04-20', 299.00),
    (35, 'INV-1136', 'mrobinson@cloudscale.com', '2023-04-22', 99.00),
    (36, 'INV-1161', 'liam.o@nexuscorp.com', '2023-05-01', 99.00),
    (37, 'INV-1162', 'eswan@storybrooke.com', '2023-05-03', 29.00),
    (38, 'INV-1163', 'noah.t@devworks.net', '2023-05-05', 299.00),
    (39, 'INV-1165', 'wclark@logistics.com', '2023-05-10', 299.00),
    (40, 'INV-9998', 'test@nexuscommerce.com', '2023-05-12', 99.00),
    (41, 'INV-1170', 'bharris@datasync.io', '2023-05-20', 299.00),
    (42, 'INV-1171', 'mrobinson@cloudscale.com', '2023-05-22', 99.00),
    (43, 'INV-1201', 'liam.o@nexuscorp.com', '2023-06-01', 99.00),
    (44, 'INV-1202', 'eswan@storybrooke.com', '2023-06-03', 29.00),
    (45, 'INV-1203', 'noah.t@devworks.net', '2023-06-05', 299.00),
    (46, 'INV-1204', 'olivia.baker@designhub.co', '2023-06-05', 29.00),
    (47, 'INV-1205', 'wclark@logistics.com', '2023-06-10', 299.00),
    (48, 'INV-1206', 'smartinez@retailpro.com', '2023-06-12', 99.00),
    (49, 'INV-1210', 'james.w@financeplus.com', '2023-06-15', 99.00),
    (50, 'INV-1211', 'ilee@marketinggurus.com', '2023-06-18', 29.00)
) AS v (record_id, invoice_number, email, invoice_date, amount)
INNER JOIN users U ON U.email = v.email
ORDER BY v.record_id;

COMMIT;

-- ---------------------------------------------------------------------
-- OPTIONAL DEMO: the legacy file cannot contain a user without an
-- invoice, so the inactive-user report returns 0 rows. Uncomment to
-- add one subscriber with no invoices and see the report find them.
-- INSERT INTO users (username, email, plan_id)
-- VALUES ('Demo Inactive', 'demo.inactive@example.com', 1);
