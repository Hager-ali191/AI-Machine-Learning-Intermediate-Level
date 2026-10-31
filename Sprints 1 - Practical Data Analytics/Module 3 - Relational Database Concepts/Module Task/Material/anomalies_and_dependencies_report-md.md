# Pharos Logistics Data Normalization Report
**Author:** [Your Name / NileBazaar Junior Database Engineer]
**Date:** [Date]
**Project:** NileBazaar & Pharos Logistics Integration

---

## 1. Identified Redundancy Examples
*Analyze the `pharos_orders_legacy.csv` flat file. Document exactly three instances where data redundancy in the `CustomerName` and `SupplierName` columns could cause update anomalies.*

**Instance 1:**
- [Identify the first redundancy example here - e.g., repeating supplier details for multiple orders]

**Instance 2:**
- [Identify the second redundancy example here - e.g., repeating customer addresses across different shipments]

**Instance 3:**
- [Identify the third redundancy example here]

---

## 2. Anomaly Explanations
*Using concrete examples directly from the Pharos Logistics dataset, write a clear explanation defining the following database anomalies.*

### Update Anomaly
**Definition:** 
[Provide definition here]

**Pharos Dataset Example:** 
[Explain how updating a specific vendor's phone number or a client's Alexandria delivery address leads to this anomaly in the flat file]

### Insert Anomaly
**Definition:** 
[Provide definition here]

**Pharos Dataset Example:** 
[Explain how adding a newly onboarded local merchant or warehouse before any orders are placed leads to this anomaly]

### Delete Anomaly
**Definition:** 
[Provide definition here]

**Pharos Dataset Example:** 
[Explain how deleting a canceled delivery record might accidentally wipe out all system records of an important supplier or customer]

---

## 3. Dependency Analysis
*Identify and document the dependencies within the flat structure. Explain why the current layout violates Second Normal Form (2NF).*

### Partial Dependencies
*List the partial dependencies found in the dataset (where a non-prime attribute depends on only part of a composite primary key).*
- [Dependency 1: e.g., CustomerAddress functionally depends on CustomerID, not the entire Order_Product composite key]
- [Dependency 2: ...]

### Transitive Dependencies
*List the transitive dependencies (where a non-prime attribute depends on another non-prime attribute).*
- [Dependency 1: e.g., SupplierPhone depends on SupplierName/ID, which depends on ProductID]
- [Dependency 2: ...]

**Why this violates 2NF:**
[Explain why the flat file structure provided by Pharos Logistics fails the 2NF requirements based on your dependency analysis above.]

---

## 4. Decomposition Steps (1NF to 2NF)
*Document the step-by-step decomposition process to transition the flat data into First Normal Form (1NF) by ensuring all values are atomic, and then into Second Normal Form (2NF) by isolating the primary entities.*

### Step 1: Transition to First Normal Form (1NF)
*Ensure all values are atomic. Detail what changes need to be made to the flat CSV structure to achieve 1NF (e.g., splitting combined fields).*
- [Detail 1NF transition steps here]

### Step 2: Transition to Second Normal Form (2NF)
*Isolate the Order, Customer, and Product entities to remove partial dependencies.*

**New Entity Structures:**
- **Customer Entity:** [List attributes here]
- **Supplier/Vendor Entity:** [List attributes here]
- **Product Entity:** [List attributes here]
- **Order Entity:** [List attributes here]
- **Order_Item (Junction) Entity:** [List attributes here]

*Note: Further normalization to 3NF and the definition of the Physical Model (including exact PostgreSQL data types and foreign key constraints) should be mapped out in your dbdiagram.io export (`pharos_normalized_ard.pdf`).*