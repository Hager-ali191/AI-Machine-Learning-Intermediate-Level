# Module 3: Relational Database Concepts
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** Pharos Logistics Legacy Data Migration & ERD Setup (requested by Laila Mahmoud, NileBazaar)

---

## 1. Module Summary

### 1.1 From Business Scenario to ERD Design
An **ERD** turns narrative business requirements into tables, keys and relationships. Most data errors start with misunderstood requirements, so the ERD acts as a shared contract between developers, analysts and business owners.

| Term | Meaning |
|---|---|
| Entity | Real-world object modeled as a table (Customer, Order) |
| Attribute | Property of an entity, stored as a column |
| Primary Key (PK) | Unique, non-null identifier of each row |
| Foreign Key (FK) | Column referencing another table's key |
| Cardinality | One-to-one, one-to-many, many-to-many |
| Constraint | Rule such as NOT NULL, UNIQUE, CHECK |

**Process:** (1) read and annotate the scenario (nouns = entities, verbs = relationships) → (2) list entities → (3) capture attributes and business rules → (4) define relationships and cardinalities → (5) draft the ERD with keys, constraints and junction tables → (6) validate with stakeholders and normalize.
**Mistakes to avoid:** business names as primary keys (use surrogate keys), forcing many-to-many into one-to-many (use a junction table), nullable FKs that should be mandatory, skipping stakeholder review.

### 1.2 Database Normalization and Design Principles
Normalization removes redundancy and prevents anomalies.

| Form | Rule | Fix |
|---|---|---|
| 1NF | Atomic values, no repeating groups | Split lists/combined fields into columns or child tables |
| 2NF | No partial dependency on part of a composite key | Move those attributes to their own table |
| 3NF | No transitive dependency (non-key → non-key) | Separate the dependent attributes |
| BCNF | Every determinant is a candidate key | Check when keys overlap |

- **Update / insert / delete anomalies** come from repeating facts in one table.
- **Denormalization** is a deliberate, benchmarked step taken only after normalizing and measuring (common in data warehouses; OLTP systems stay normalized).

### 1.3 Setting Up Your PostgreSQL Environment
1. Install: `sudo apt update && sudo apt install -y postgresql postgresql-contrib`; check with `psql --version`
2. Become superuser: `sudo -u postgres psql`
3. Create an app role: `CREATE ROLE sprints WITH LOGIN PASSWORD 'sprints' CREATEDB;`
4. Create the project database: `CREATE DATABASE ecommerce OWNER sprints;` and list with `\l`
5. Install pgAdmin and register a server on `localhost:5432`
6. Enforce standards: typed columns, constraints, domains, **snake_case** names

Remember: never use the `postgres` superuser in applications; default port is 5432; domains centralize validation rules (e.g. email regex).

---

## 2. Task Overview

**Scenario:** Pharos Logistics tracks shipments, vendors and clients in one flat spreadsheet (`pharos_orders_legacy.csv`: 25 rows, 8 columns). NileBazaar needs it analysed, normalized and designed as a relational PostgreSQL model, and the local environment verified.

### Deliverables (matches the expected submission tree)
```
pharos-logistics-refactor/
├── data/
│   └── pharos_orders_legacy.csv
├── docs/
│   ├── anomalies_and_dependencies_report.md
│   ├── pharos_normalized_ard.pdf        (3 pages: conceptual, logical, physical)
│   └── pharos_normalized_ard.dbml       (extra: source for dbdiagram.io)
├── logs/
│   └── psql_setup_log.txt
└── README.md                            (extra: this file)
```

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | Exactly three redundancy instances in `CustomerName` / `SupplierName` | ✅ Kareem Ali (5 rows), Alexandria Textiles (8), Delta Electronics (9) |
| 2 | Define update, insert, delete anomalies with Pharos examples | ✅ |
| 3 | All partial and transitive dependencies; why 2NF is violated | ✅ |
| 4 | Step-by-step 1NF → 2NF decomposition (Order, Customer, Product entities) | ✅ |
| 5 | Every CSV column mapped to the new tables (zero data loss) | ✅ column-mapping table |
| 6 | ERD with conceptual, logical and physical models, FKs and cardinality | ✅ 3 pages, crow's foot notation |
| 7 | `sudo -u postgres psql` then `\l`, saved in `psql_setup_log.txt` | ✅ see note below |

---

## 3. Key Findings
- **Composite key:** (`OrderID`, `ProductName`). `OrderID` repeats (ORD-1001 has two lines).
- **Partial dependencies:** `OrderID → CustomerName, CustomerAddress`; `ProductName → SupplierName, SupplierContact` (and unit price).
- **Transitive dependencies:** `ProductName → SupplierName → SupplierContact`; `OrderID → CustomerName → CustomerAddress`; `TotalPrice_EGP` is derived (`Quantity × unit price`).
- **1NF fix:** `CustomerAddress` combines street and city, so it is split into `street_address` and `city`.

## 4. Final Normalized Model

| Table | PK | FKs | Other columns |
|---|---|---|---|
| `customers` | `customer_id` | – | `customer_name`, `street_address`, `city` |
| `suppliers` | `supplier_id` | – | `supplier_name` (unique), `supplier_contact` |
| `products` | `product_id` | `supplier_id` | `product_name` (unique), `unit_price_egp` |
| `orders` | `order_id` | `customer_id` | `order_number` (unique, e.g. ORD-1001) |
| `order_items` | (`order_id`, `product_id`) | `order_id`, `product_id` | `quantity`, `unit_price_egp` |

Cardinalities: Customer 1–N Order · Order 1–N Order_Item · Product 1–N Order_Item (Order ↔ Product is many-to-many) · Supplier 1–N Product.
The flat file's 25 rows become 7 customers, 4 suppliers, 6 products, 24 orders and 25 order items.

## 5. Testing Performed
- The model was built in **PostgreSQL 16** (PKs, FKs, `NOT NULL`, `UNIQUE`, `CHECK`) and all 25 CSV rows were loaded.
- A join across the five tables rebuilt the original CSV exactly (all rows, all 8 columns, `TotalPrice_EGP` included).
- The dependency claims in the report were checked against the data (one customer per order, one supplier per product, constant unit price per product, one address per customer).

## 6. Important Notes Before You Submit

1. **ERD PDF:** the task asks for a diagram made in dbdiagram.io or draw.io. I could not use those web tools here, so the PDF was drawn with Graphviz in the same notation. To use dbdiagram.io itself, paste `docs/pharos_normalized_ard.dbml` into https://dbdiagram.io/d and export a PDF. It describes the same physical model.
2. **Setup log:** `logs/psql_setup_log.txt` contains real output from PostgreSQL 16.15 on Ubuntu 24.04, but it was produced in my sandbox, not on your computer. Please regenerate it on your own machine so it shows your environment:
   ```bash
   script -q logs/psql_setup_log.txt
   psql --version
   sudo -u postgres psql
   \l
   \q
   exit
   ```
   (`script` records everything typed and printed in the terminal.)
3. **Author:** the report is signed "NileBazaar Junior Database Engineer"; add your own name if you wish.
4. **Observation:** Laila's email says Pharos serves Alexandria deliveries, but the data also contains Cairo customers (Mona Youssef, Sara Ibrahim, Hoda Mostafa), so the `city` column is kept free-form rather than hard-coded to Alexandria.
