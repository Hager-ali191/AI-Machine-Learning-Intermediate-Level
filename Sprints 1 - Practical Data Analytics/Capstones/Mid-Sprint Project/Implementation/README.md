# Mid-Sprint Project: SaaS Anomaly Resolution & Schema Migration
**Nexus Commerce Solutions · Requested by Elena Rostova, VP of Product**
**AI & Machine Learning – Intermediate Level · Sprint 1 (applies Modules 2–4: database design, normalization and SQL)**

---

## 1. Project Overview
Nexus Commerce's billing system stores subscribers, plans and invoices in **one flat table**. The redundancy causes update, insert and delete anomalies (for example, a price change means editing many rows). The task: document the anomalies, decompose the table to at least 2NF (with BCNF in mind), design an ERD, write the DDL and a simulated `ALTER TABLE` migration, and deliver SQL reports and a targeted data cleanup, all tested locally in PostgreSQL.

## 2. Deliverables

```
midsprint_project/
├── deliverables/
│   ├── docs/
│   │   ├── 01_normalization_report.md     ← anomalies + 1NF→2NF→3NF strategy
│   │   └── 02_normalized_erd.pdf          ← ERD (Plans, Users, Invoices)
│   ├── scripts/
│   │   ├── 03_schema_ddl.sql              ← CREATE TABLE x3 + ALTER TABLE migration
│   │   ├── 03b_seed_legacy_data.sql       (extra) loads the 50 legacy rows
│   │   └── 04_reports.sql                 ← 5 reports/cleanup statements
│   └── README.md                          ← this file
└── data/
    └── legacy_subscriptions.csv           (provided input, for reference)
```
The four required deliverables plus `README.md` match the expected submission tree. `03b_seed_legacy_data.sql` and the `data/` folder are optional extras.

## 3. The Legacy Data
50 rows × 8 columns (`record_id`, `user_name`, `user_email`, `plan_name`, `plan_price`, `invoice_id`, `invoice_date`, `invoice_amount`); 11 subscribers, 3 real plans (Starter $29, Growth $99, Enterprise $299), no missing values. Quality issues: the plan typo **"Growht"** (2 rows), a **"Test User"** account, and a **$0.00 test invoice** (INV-9999).

## 4. How the Requirements Are Met

| # | Requirement | Where | Status |
|---|---|---|---|
| 1 | One update, one insert and one delete anomaly + 1NF → 2NF strategy | `01_normalization_report.md` §3–4 | ✅ price change (18 rows), plan/user before invoice, deleting Mia Robinson's invoices |
| 2 | ERD with Users, Plans, Invoices; serial PKs; FKs Users→Plans, Invoices→Users | `02_normalized_erd.pdf` | ✅ crow's foot notation |
| 3 | DDL for Plans, Users, Invoices: `serial` ids, NOT NULL names, UNIQUE emails | `03_schema_ddl.sql` | ✅ |
| 4 | ALTER TABLE: add `discount_code` to Invoices, widen `username`, drop `legacy_notes` | `03_schema_ddl.sql` | ✅ 50 → 100 characters |
| 5 | Three-table INNER JOIN (name, plan, amount) with aliases U, P, I | `04_reports.sql` §1 | ✅ 50 rows |
| 6 | LEFT JOIN: users with `Invoice ID IS NULL` | `04_reports.sql` §2 | ✅ 0 rows (see note) |
| 7 | Revenue per plan: GROUP BY + SUM + HAVING > $1,000 | `04_reports.sql` §3 | ✅ |
| 8 | Top 5 users: ORDER BY DESC + LIMIT 5 | `04_reports.sql` §4 | ✅ |
| 9 | One UPDATE (plan typo) and one DELETE (test invoice), each with a strict WHERE on an ID, no TRUNCATE | `04_reports.sql` §5 | ✅ `plan_id = 4`, `invoice_id = 15` |
| 10 | Runs without errors on PostgreSQL 14+; capitalized keywords; consistent indentation | all scripts | ✅ tested on PostgreSQL 16 |

## 5. Results (with the legacy data loaded)

| Report | Result |
|---|---|
| Three-table join | 50 rows (user, plan, amount) |
| Inactive users | **0 rows**: every legacy user has an invoice (the flat table cannot even represent an uninvoiced user, which is the insert anomaly) |
| Revenue per plan (> $1,000) | Enterprise **$4,485.00**, Growth **$1,782.00** (Starter $435.00 and "Growht" $99.00 excluded) |
| Top 5 customers | Noah Torres $1,794; William Clark $1,794; Benjamin Harris $897; Liam O'Connor $594; Sophia Martinez $495 (ties are broken alphabetically) |
| Cleanup | `plans.plan_id = 4` "Growht" → "Growth"; `invoices.invoice_id = 15` (INV-9999, $0.00) deleted; 49 invoices remain |

After the cleanup, revenue for "Growth" becomes $1,881.00 because the corrected plan now groups with the original Growth plan.

## 6. How to Run
**pgAdmin 4:** create a database (e.g. `nexus`), open **Tools → Query Tool**, then open and run (F5) in this order:
1. `scripts/03_schema_ddl.sql`
2. `scripts/03b_seed_legacy_data.sql` (loads the sample data)
3. `scripts/04_reports.sql`

**psql:**
```bash
createdb nexus
psql -d nexus -f deliverables/scripts/03_schema_ddl.sql
psql -d nexus -f deliverables/scripts/03b_seed_legacy_data.sql
psql -d nexus -f deliverables/scripts/04_reports.sql
```
`03_schema_ddl.sql` starts with `DROP TABLE IF EXISTS`, so it can be re-run safely (it recreates the tables, so re-run the seed afterwards).

## 7. Testing Performed
- All scripts were executed on **PostgreSQL 16** with `ON_ERROR_STOP`; the DDL was run twice to confirm it is re-runnable.
- The 50 legacy rows were loaded (4 plans, 11 users, 50 invoices) and a join **rebuilt the original CSV exactly**.
- Constraints were checked: a NULL username, a duplicate email and an invoice for a non-existent user were all rejected.
- The inactive-user query was tested with a temporary demo user and correctly returned them.
- `04_reports.sql` contains no `TRUNCATE`; both change statements affect exactly one row.

## 8. Design Decisions and Notes
- **legacy_notes** is created in `users` as a deprecated column so the migration has something realistic to drop.
- **`plan_name` is not UNIQUE (yet):** the brief asks only for NOT NULL names and UNIQUE emails, and the data holds the misspelled duplicate plan "Growht". Fixing the spelling therefore leaves two plans named "Growth"; the report explains how to merge them and then add `UNIQUE (plan_name)` for BCNF. Reports group by plan name, so they are not affected.
- **`invoice_number`** keeps the legacy ids (`INV-1001`), and **`amount`** stores the price actually charged.
- **The inactive-user report returns 0 rows** with this data. The seed file includes a commented-out demo user you can uncomment to see it work.
- **Remaining test data:** the Test User account and its $99.00 invoice (INV-9998) are not removed, because the brief asks for one invoice deletion. They still count in revenue.
- **ERD tool:** the brief names Lucidchart, which I can't use here. The ERD PDF was generated with Graphviz in standard crow's foot notation. Redraw it in Lucidchart and export a PDF if your submission requires that tool; the tables and relationships are listed in the report and the DDL.
- **Names:** no personal name appears in the deliverables.
