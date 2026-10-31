# Module 4: SQL Basics
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** Executive Sales Report & Data Quality Check (CartGrid E-commerce, requested by Elena Rodriguez)

---

## 1. Module Summary

### 1.1 Schema Definition and Table Management (DDL)
| Command | Purpose |
|---|---|
| `CREATE TABLE` | Define columns, data types, constraints |
| `ALTER TABLE` | Add/modify/drop columns and constraints (`ADD COLUMN`, `ALTER COLUMN ... SET NOT NULL`) |
| `TRUNCATE` | Remove all rows fast; `RESTART IDENTITY` resets the counter |
| `DROP TABLE` | Delete the table permanently |

Remember: don't `TRUNCATE` a table referenced by a foreign key; `DROP` can't be rolled back after commit; `ALTER` on large tables can lock them; take backups before running DDL in production.

### 1.2 CRUD Operations and Query Enhancements
- `INSERT INTO t (cols) VALUES (...) RETURNING id;` · `SELECT cols FROM t WHERE ...;` · `UPDATE t SET ... WHERE ...;` · `DELETE FROM t WHERE ...;`
- **Always** use `WHERE` on `UPDATE`/`DELETE` (test it with a `SELECT` first).
- Enhancements: aliases (`AS`), `CONCAT` / `CONCAT_WS`, `DISTINCT`. Wrap nullable columns in `COALESCE` before concatenating. Avoid `SELECT *` in application code.

### 1.3 Filtering and Sorting
| Tool | Use |
|---|---|
| `WHERE` + `AND` / `OR` / `NOT` | Filter rows |
| `BETWEEN` (inclusive), `IN`, `IS NULL` | Ranges, lists, nulls |
| `LIKE` / `ILIKE` with `%` | Pattern matching (`ILIKE` is case-insensitive, PostgreSQL only) |
| `ORDER BY ... ASC/DESC [NULLS LAST]` | Sorting |
| `LIMIT` / `OFFSET`, key-set pagination | Paging; key-set is faster on large tables |

String literals need single quotes. `LIKE '%term%'` can't use a normal index. Row order is not guaranteed without `ORDER BY`.

### 1.4 Aggregation and Analytics
- Aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`. `COUNT(*)` counts all rows, `COUNT(col)` skips NULLs.
- `GROUP BY` buckets rows; `HAVING` filters the **groups** (after aggregation); `WHERE` filters rows **before**.
- Window functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK` with `OVER (PARTITION BY ... ORDER BY ...)`) rank or total without collapsing rows.
- Every non-aggregated column in `SELECT` must be in `GROUP BY`.

### 1.5 Joining Tables
| Join | Keeps |
|---|---|
| `INNER JOIN` | Only matching rows |
| `LEFT JOIN` | All left rows; NULLs where the right has no match |
| `RIGHT JOIN` | All right rows |
| `FULL OUTER JOIN` | All rows from both sides |
| `SELF JOIN` | Table joined to itself (e.g. employee → manager) |
| `CROSS JOIN` | Every combination (Cartesian product) |

Always write an explicit `ON` clause, use unique table aliases, and list columns explicitly. A `WHERE` filter on the right-hand table of a `LEFT JOIN` turns it into an inner join; the exception is the orphan pattern `LEFT JOIN ... WHERE right.id IS NULL`.

---

## 2. Task Overview

**Scenario:** Elena (Senior DBA) needs the end-of-month executive sales report for the VP of Operations, plus a data-quality check for orders that are not tied to a real customer. The setup script intentionally leaves out the foreign key on `orders.customer_id`, so orphan orders are possible.

### Deliverables (matches the expected submission tree)
```
project/
├── cartgrid_setup.sql          (provided script, unchanged)
├── sql_syntax_guide.md         (provided guide, unchanged)
├── sales_report_queries.sql    ← deliverable
├── report_export.csv           ← deliverable
├── vp_email_reply.txt          ← deliverable
└── README.md                   (extra: this file)
```

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | Setup run, CRUD verified, setup-complete comment at the top of the script | ✅ Sections header + 0 (CRUD in a rolled-back transaction) |
| 2 | Inner join `customers C` + `orders O` with single-letter aliases | ✅ Section 1 (47 rows) |
| 3 | Second inner join to `products P` on `O.product_id = P.id` | ✅ Section 2 |
| 4 | `WHERE` completed orders `AND` `category LIKE 'Tech%'` | ✅ Section 3 (36 rows) |
| 5 | `SUM(P.price)`, `GROUP BY` first/last name, `HAVING` > 50, exported to CSV | ✅ Section 4, 18 rows |
| 6 | Separate orphan query: `LEFT JOIN` + `WHERE C.id IS NULL` | ✅ Section 5, 3 rows |
| 7 | VP email states the orphan count and explains INNER vs LEFT JOIN simply | ✅ 3 orphans |

## 3. Results

| Metric | Value |
|---|---|
| Total orders | 50 |
| Rows returned by INNER JOIN (customers ↔ orders) | 47 |
| Rows returned by LEFT JOIN (orders → customers) | 50 |
| **Orphan orders** | **3** (order IDs 48, 49, 50; customer IDs 999, 888, 777) |
| Orphan value | $950.00 (4K Monitor 350 + SoundMax Headphones 150 + Gaming Console 450), all "Completed" Tech orders |
| Completed Tech orders / customers over $50 | 36 orders → 18 customers |
| Report total | $11,670.00 (top customer: Emma Smith, $1,820.00) |
| Completed Tech revenue including orphans | $12,620.00 (orphans ≈ 7.5%) |

Every customer with a completed Tech order cleared the $50 threshold, so the `HAVING` clause did not drop anyone here.

## 4. How to Run in pgAdmin 4
1. Create a database (right-click **Databases → Create → Database**, e.g. `cartgrid`).
2. Open **Tools → Query Tool**, load `cartgrid_setup.sql`, and execute (F5).
3. Open `sales_report_queries.sql` in the Query Tool and run it. To run one query at a time, select it and press F5.
4. To re-create the CSV, run the Section 4 query, then click **Download as CSV** in the results toolbar (or in psql: `\copy (<query>) TO 'report_export.csv' CSV HEADER`).

## 5. Notes
- **Status spelling:** values in `orders.status` are capitalised (`'Completed'`). The syntax guide's example shows `P.status = 'completed'`, which would fail because `status` lives in `orders`, not `products`, and the case differs. The script uses `O.status = 'Completed'`.
- **Spec wording:** "Wear Condition" and "End" in the task are nicknames for `WHERE` and `AND` (explained in the syntax guide).
- **Grouping by name:** the task says to group by first and last name. There are no duplicate names in this data, but in production, grouping by `C.id` as well would be safer.
- **Testing:** the setup script and `sales_report_queries.sql` were run end to end on PostgreSQL 16, with no errors. The CSV was produced from the exact Section 4 query.
- **Email:** the VP's name and your name weren't provided, so the greeting is "Hi," and the signature is the job title only. Add your name before sending.
- **Follow-up suggestion (not done):** once the 3 orphans are resolved, add a foreign key from `orders.customer_id` to `customers.id` so they can't recur.
