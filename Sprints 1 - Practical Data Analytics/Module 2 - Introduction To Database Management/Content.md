# Module 2: Introduction to Database Management
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** E-Commerce DB Schema Review & Implementation (AeroGlobal, requested by Kenji Sato)

---

## 1. Module Summary

### 1.1 Basics of Databases
A database is a structured, electronically stored collection of data managed by a **DBMS**, which provides storage, retrieval, security and concurrency control. It replaces ad-hoc flat files.

| Term | Meaning |
|---|---|
| DBMS | Software layer that controls storage, retrieval, security, concurrency |
| ACID | Atomicity, Consistency, Isolation, Durability: reliable transactions |
| Data integrity | Correct, consistent data enforced by constraints |
| Concurrency | Many users working at once without conflict |
| Scalability | Keeping performance as data/workload grows (vertical or horizontal) |

Remember: wrap related statements in `BEGIN ... COMMIT` for atomicity; use least-privilege access; index large tables.

### 1.2 Relational vs Non-relational
| | Relational (SQL) | Non-relational (NoSQL) |
|---|---|---|
| Structure | Tables, rows, fixed schema | Documents, key-value, column, graph; flexible schema |
| Consistency | ACID | Often BASE (eventual consistency) |
| Scaling | Typically vertical first | Horizontal by default |
| Best for | Transactions, strict integrity (payments, orders) | Fast-changing data, huge scale |

Choosing: clarify consistency needs, data volume/velocity, query patterns, schema evolution, team skills. Many systems combine both (e.g. PostgreSQL for orders, MongoDB for product metadata).

### 1.3 Relational Database
Tables of rows (records) and columns (attributes). **Primary keys** uniquely identify rows; **foreign keys** link tables. Constraints (`NOT NULL`, `UNIQUE`, `CHECK`) protect integrity. **Normalization** (1NF → 2NF → 3NF) removes redundancy and anomalies. Design steps: define entities, assign PKs, set relationships, apply constraints and indexes, normalize, plan backups.

### 1.4 DBMS
Provides data definition (DDL), data manipulation (DML), integrity and security, storage optimization (indexes), and backup/recovery. Families: RDBMS (PostgreSQL, MySQL), NoSQL (MongoDB), in-memory (Redis). Common mistakes: tables without primary keys, no backups, heavy analytics on the production OLTP database.

### 1.5 Database Models and Schema
Three abstraction levels: **conceptual** (entities and relationships) → **logical** (attributes, keys, constraints) → **physical** (tables, indexes, data types in a specific DBMS). An **ERD** (Peter Chen, 1976) draws entities, attributes and cardinality. Many-to-many relationships use junction tables. Prefer surrogate integer keys over natural keys such as email; keep foreign keys.

### Normal forms at a glance
| Form | Rule | Typical fix |
|---|---|---|
| 1NF | One value per cell, rows uniquely identified | Split multi-valued columns |
| 2NF | No partial dependency on part of a composite key | Move attributes into the table they depend on |
| 3NF | No transitive dependency (non-key → non-key), no derived data | Separate lookup tables, drop calculated columns |

---

## 2. Task Overview

**Scenario:** AeroGlobal's sales team mocked up an in-flight e-commerce feature as one big spreadsheet (`draft_schema.csv`: 20 rows, 11 columns). Kenji asked for (a) a plain-language explanation of ERDs and entities for the sales team, (b) a review of the spreadsheet's problems, (c) a 3NF design, and (d) a PostgreSQL DDL script.

### Deliverables
| File | Purpose |
|---|---|
| `stakeholder_explanation.md` | 3-paragraph email to sales, anomaly review, 3NF tables with keys and columns, ERD |
| `schema.sql` | PostgreSQL `CREATE TABLE` script for the normalized schema |
| `draft_schema.csv` | Original input, included to match the submission tree |
| `README.md` | This document |

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | 2–3 paragraph email to sales explaining ERD and entity; contrasts with "flat file" systems (exact term) | ✅ 3 paragraphs |
| 2 | At least 3 specific redundancies/anomalies from the CSV | ✅ 8 documented (redundancy, update, insert, delete, derived data) |
| 3 | 3NF design with tables, PKs, FKs and columns | ✅ 6 tables |
| 4 | `schema.sql` with `CREATE TABLE`, explicit PKs and correct FKs | ✅ |
| 5 | At least one `NOT NULL` on critical fields | ✅ names, emails, dates, quantities, prices, FKs |
| 6 | Header comment: avoids silos and supports horizontal scaling | ✅ |
| 7 | Comment: how PK/FK constraints help atomicity in an order transaction | ✅ |
| 8 | Standard formatting, PostgreSQL types, semicolons | ✅ |

---

## 3. The Design

```
customers ──< orders ──< order_items >── products >── categories
                                            │
                                            └──────── suppliers
```

| Table | PK | FKs |
|---|---|---|
| `customers` | `customer_id` | none |
| `suppliers` | `supplier_id` | none |
| `categories` | `category_id` | none |
| `products` | `product_id` | `category_id`, `supplier_id` |
| `orders` | `order_id` | `customer_id` |
| `order_items` | (`order_id`, `product_id`) | `order_id`, `product_id` |

Key decisions:
- Original IDs (`ORD-…`, `PROD-…`) are kept as `UNIQUE` business codes; integer surrogate keys are used for joins.
- `TotalPrice` is dropped (derived data); line total = `quantity * unit_price`.
- `order_items.unit_price` stores the price paid at purchase time so history is preserved.
- `CHECK` constraints prevent negative prices and non-positive quantities.
- Indexes on foreign-key columns support fast joins.
- `DROP TABLE IF EXISTS` lines make the script safe to re-run.

## 4. Testing Performed
The script was run on **PostgreSQL 16**:
- Runs twice without errors.
- All 20 CSV rows were loaded (8 customers, 5 suppliers, 6 categories, 7 products, 15 orders, 20 order lines) and a join rebuilt the original spreadsheet exactly.
- A transaction inserting an order line for a non-existent product failed on the foreign key and rolled back.
- A customer with a `NULL` name and a duplicate email were both rejected.

## 5. How to Run
```bash
createdb aeroglobal
psql -d aeroglobal -f schema.sql
```

## 6. Before Submitting
Submit the files in the expected tree:
```
ecommerce_project/
├── draft_schema.csv
├── stakeholder_explanation.md
└── schema.sql
```
`README.md` is optional extra documentation. The email is signed by "The Database Team"; replace it with your name if you prefer.
