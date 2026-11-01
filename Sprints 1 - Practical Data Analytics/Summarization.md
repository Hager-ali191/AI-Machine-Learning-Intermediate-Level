# Sprint 1 Summary: Practical Data Analytics
**AI & Machine Learning – Intermediate Level**

Sprint 1 takes data from **idea → storage → query → analysis → visualization**: understanding the data science process, designing and querying relational databases, analyzing data in Python, and presenting it visually. A **mid-sprint project** puts the database and SQL modules into practice, and a **capstone** at the end combines everything.

```
Data Science ➜ Databases (design) ➜ SQL ➜ MID-SPRINT PROJECT ➜ NumPy/Pandas ➜ Visualization ➜ Capstone
  Module 1       Modules 2–3        Mod 4   (applies Modules 2–4)   Module 5       Module 6
```

---

## Module 1: Introduction to Data Science
- **Data science** = statistics + computer science + domain expertise. Key terms: machine learning, recommendation engine, predictive analytics, structured vs unstructured data.
- **Roles:** data engineer (pipelines), data scientist (models/insight), ML engineer (deployment), NLP engineer (language), data analyst (reporting).
- **The 7-step process:** problem definition → data collection → cleaning → EDA → model selection and training → evaluation and tuning → deployment and monitoring. Cleaning takes 60–80% of the time.
- **Decision-making (DDDM):** adds feature engineering, A/B testing, dashboards; SQL, Python and Tableau support different stages.
- **Careers:** Python, R, SQL plus soft skills (communication matters as much as algorithms).
- **Task:** pitch a recommendation engine to a non-technical executive (analogy, 7-step workflow, tool-to-stage mapping CSV).

## Module 2: Introduction to Database Management
- A **DBMS** manages storage, security and concurrency; **ACID** (Atomicity, Consistency, Isolation, Durability) makes transactions reliable.
- **Relational** (tables, keys, strict schema, vertical scaling first) vs **non-relational** (flexible schema, BASE, horizontal scaling). Pick by consistency, volume, query pattern and skills.
- **Models:** conceptual → logical → physical; **ERD** shows entities and relationships; PK and FK enforce integrity; many-to-many needs a junction table.
- **Task:** review a flat spreadsheet, normalize it to 3NF, write PostgreSQL DDL (`CREATE TABLE`, keys, `NOT NULL`).

## Module 3: Relational Database Concepts
- **From scenario to ERD:** nouns = entities, verbs = relationships; add attributes, keys, cardinality; validate with stakeholders.
- **Normalization:** 1NF (atomic values) → 2NF (no partial dependency) → 3NF (no transitive dependency) → BCNF; fixes **update, insert and delete anomalies**. Denormalize only after measuring.
- **PostgreSQL setup:** install, `sudo -u postgres psql`, create a role and database, `\l`, pgAdmin; use snake_case and constraints/domains.
- **Task:** find anomalies and dependencies in a legacy shipment file, decompose to 2NF/3NF, design a conceptual/logical/physical ERD, log the psql setup.

## Module 4: SQL Basics
- **DDL:** `CREATE`, `ALTER`, `TRUNCATE`, `DROP`. **CRUD:** `INSERT … RETURNING`, `SELECT`, `UPDATE`, `DELETE` (always use `WHERE`).
- **Filtering and sorting:** `WHERE`, `AND/OR`, `BETWEEN`, `LIKE/ILIKE`, `ORDER BY`, `LIMIT/OFFSET`.
- **Aggregation:** `COUNT/SUM/AVG`, `GROUP BY`, `HAVING` (filters groups), window functions (`RANK`, `ROW_NUMBER`).
- **Joins:** `INNER`, `LEFT`, `RIGHT`, `FULL`, `SELF`, `CROSS`; use aliases and explicit `ON` clauses; `LEFT JOIN … WHERE x IS NULL` finds orphan records.
- **Task:** executive sales report (3-table join, filter, aggregate, CSV export) plus an orphan-order data quality check (3 of 50 orders had no customer).

## Mid-Sprint Project: SaaS Anomaly Resolution & Schema Migration
*Applies Modules 2–4 (database design, normalization, SQL) to a realistic billing-system problem for Nexus Commerce Solutions.*
- **Problem:** subscribers, plans and invoices lived in one flat table (50 rows), causing **update, insert and delete anomalies** (e.g. one price stored on 20 rows) and data-quality issues (a plan typo "Growht", a test account, a $0.00 test invoice).
- **Design:** decomposed the table through **1NF → 2NF → 3NF/BCNF** into **Plans, Users and Invoices** (serial primary keys; foreign keys Users→Plans and Invoices→Users), documented in a stakeholder-ready report and a crow's foot **ERD** (PDF).
- **DDL and migration:** `CREATE TABLE` with `NOT NULL`, `UNIQUE` and `CHECK` constraints, plus simulated `ALTER TABLE` changes: add `discount_code`, widen `username` (50 → 100), drop the deprecated `legacy_notes`.
- **SQL reports:** three-table `INNER JOIN` with aliases (U, P, I); `LEFT JOIN … IS NULL` for inactive users; revenue per plan with `GROUP BY` + `SUM` + `HAVING > 1000` (Enterprise $4,485, Growth $1,782); top 5 customers with `ORDER BY … DESC LIMIT 5`.
- **Safe cleanup:** one `UPDATE` (plan typo) and one `DELETE` (test invoice), each pinned to a specific ID with `WHERE`; no `TRUNCATE`.
- **Verified:** a join across the new tables rebuilt all 50 legacy rows exactly; scripts run cleanly on PostgreSQL.

---

## Module 5: Data Analysis with Python
- **NumPy:** `ndarray` (one dtype), vectorization, broadcasting, slicing = view, boolean masks, `reshape/ravel/flatten`, stacking and splitting, `np.linalg` (`@`, `det`, `inv`, `solve`).
- **Pandas:** `Series`/`DataFrame`, `read_csv`, `head/info/describe`, `loc/iloc`, missing data (`isnull`, `fillna`, `dropna`), `pivot/stack`, `groupby().agg()`, `sort_values`, DateTime index.
- **Advanced:** think in arrays, not loops: `np.where`, vectorized feature engineering, one-hot encoding, Polars for very large data.
- **Task:** rewrite a slow for-loop script as a strictly vectorized pipeline (`np.where`, broadcasting, `groupby/agg`, CSV export).

## Module 6: Data Visualization with Python
- **Principles:** simplicity, clarity, accuracy, efficiency; match chart to data (bars for categories, lines for trends, scatter for relationships, histograms for distributions); bars start at zero.
- **Matplotlib:** Figure/Axes, `plot/scatter/bar/hist/boxplot`, subplots, annotations, 3-D, `savefig(dpi=300)`.
- **Seaborn:** statistical plots straight from DataFrames (`histplot`, `boxplot`, `violinplot`, `heatmap`, `pairplot`).
- **Plotly:** interactive charts (zoom, pan, hover, legend toggling), `make_subplots` dashboards, animation (`animation_frame`), geo maps (`choropleth`, `scatter_geo`), `write_html` export.
- **PygWalker:** drag-and-drop exploration inside Jupyter.
- **Task:** two-panel Plotly dashboard, animated scatter, interactive HTML export, usability evaluation.

---

## Capstone: GlobalMart Q4 Sales Dashboard
Clean and visualize a raw retail extract end to end:
- Loaded the CSV and checked `.shape` and `.dtypes`; fixed `Revenue` from text (`$599.98`) to `float64` with element-wise string replacement.
- **Boolean masking** removed 113 invalid records (`Quantity <= 0`), leaving 387; verified 0 invalid rows remain.
- Wrote a visualization strategy brief (bar chart for categorical, histogram for continuous), built a Matplotlib bar chart of sales by region, and an interactive Plotly scatter (Quantity vs Revenue, hover = category), exported as `dashboard.html`.
- Finding: North America ≈ 49% of valid revenue ($31.9K of $65.2K).

---

## Skills Cheat Sheet
| Area | Core tools / ideas |
|---|---|
| Process | 7-step data science workflow, tool-to-stage mapping |
| Databases | PostgreSQL, ERD, PK/FK, 1NF–3NF/BCNF, ACID, DDL, `ALTER TABLE` migrations |
| SQL | CRUD, `WHERE`/`LIKE`, `GROUP BY`/`HAVING`, joins, orphan checks |
| Python analysis | NumPy vectorization and masks, Pandas `groupby/agg`, `np.where` |
| Visualization | Matplotlib, Seaborn, Plotly (subplots, animation, HTML export) |
| Professional | Stakeholder emails and reports, non-technical explanations, documentation, data-quality thinking |

**Big ideas to remember**
1. Clean, well-structured data matters more than clever algorithms.
2. Store each fact once (normalization) and let keys connect it; migrate schemas safely and clean data with targeted `WHERE` statements.
3. Vectorize instead of looping; mask instead of iterating.
4. Pick the chart to match the question, and keep it uncluttered.
5. Always validate: check shapes, dtypes, counts and totals before trusting results.
