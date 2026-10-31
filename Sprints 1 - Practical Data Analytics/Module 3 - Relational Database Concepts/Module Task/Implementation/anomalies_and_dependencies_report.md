# Pharos Logistics Data Normalization Report
**Author:** NileBazaar Junior Database Engineer
**Date:** October 31, 2026
**Project:** NileBazaar & Pharos Logistics Integration

---

## 1. Identified Redundancy Examples
*Analysis of `pharos_orders_legacy.csv`: 25 rows (order lines), 24 orders, 8 columns. Every row repeats the customer, supplier and product details of its order line.*

**Instance 1: Customer "Kareem Ali" (`CustomerName`)**
- Kareem Ali and his address `15 Saad Zaghloul St, Alexandria` are typed out on **5 rows** (ORD-1001 twice, ORD-1005, ORD-1011, ORD-1016). If he moves or his name is corrected, all 5 rows must be edited. Missing one leaves the file saying he lives at two addresses. The same pattern affects Mona Youssef, Ahmed Hassan, Sara Ibrahim and Tarek Mansour (4 rows each).

**Instance 2: Supplier "Alexandria Textiles" (`SupplierName`)**
- Alexandria Textiles and its contact `010-1234-5678` appear on **8 rows** (ORD-1001 twice, 1006, 1008, 1009, 1012, 1019, 1023), across two products (Egyptian Cotton Sheets and Cotton Towel Set). One phone-number change means 8 edits, and a partial update creates two "versions" of the same supplier.

**Instance 3: Supplier "Delta Electronics" (`SupplierName`)**
- Delta Electronics and its contact `011-9876-5432` appear on **9 rows** (ORD-1002, 1005, 1007, 1013, 1014, 1017, 1018, 1021, 1024), the most repeated entity in the file, covering Smart Fan and LED Bulb 9W. A renamed company or a new phone number would have to be fixed on every one of those rows.

---

## 2. Anomaly Explanations

### Update Anomaly
**Definition:**
An update anomaly happens when a single real-world fact is stored in many rows, so changing it requires editing every copy. If any copy is missed, the data contradicts itself.

**Pharos Dataset Example:**
Delta Electronics changes its phone number from `011-9876-5432`. The number is stored on 9 rows, so 9 rows must be updated. If only 7 are corrected, the file lists two different numbers for the same vendor, and nobody can tell which is right. The same happens when Kareem Ali moves from `15 Saad Zaghloul St, Alexandria`: 5 rows hold his address, so a delivery for ORD-1016 could still go to the old street.

### Insert Anomaly
**Definition:**
An insert anomaly happens when a new fact cannot be recorded because it depends on unrelated data that does not exist yet. In a flat file, the row key requires an order, so nothing can be stored before an order exists.

**Pharos Dataset Example:**
A new local merchant (supplier) is onboarded in Alexandria but has no orders yet. There is nowhere to record its name and phone number, because every row needs an `OrderID`, a `CustomerName` and a `ProductName`. The same applies to a new customer who registers an address before placing a first order, or a new product that has not been sold. The only workaround is a dummy order with blank or fake values, which pollutes the data.

### Delete Anomaly
**Definition:**
A delete anomaly happens when removing one fact unintentionally destroys other, unrelated facts that were stored in the same row.

**Pharos Dataset Example:**
Youssef Kamal appears on only two rows, ORD-1017 (Smart Fan) and ORD-1018 (LED Bulb 9W). If both deliveries are canceled and their rows deleted, the file loses every record that Youssef Kamal exists and that his address is `14 Smouha Club St, Alexandria`. In the same way, if every Handwoven Rug row were removed (ORD-1003, 1010, 1016, 1022), the only record of the supplier Cairo Crafts Co. and its contact `012-3333-4444` would disappear with it.

---

## 3. Dependency Analysis
*Candidate (composite) primary key of the flat file: **(OrderID, ProductName)**. `OrderID` alone is not unique (ORD-1001 has two lines) and no (OrderID, ProductName) pair repeats. Dependencies below were checked against the data: e.g. each OrderID maps to exactly one customer, each ProductName to exactly one supplier, and each product has one constant unit price.*

### Partial Dependencies
*(a non-key attribute depends on only part of the composite key)*
- **OrderID → CustomerName, CustomerAddress:** the customer and address are fixed by the order alone and ignore which product is on the line. They are repeated for every line of the same order (e.g. ORD-1001).
- **ProductName → SupplierName, SupplierContact:** the supplier and contact are fixed by the product alone and ignore which order it is in. They are repeated every time the product is ordered (e.g. Smart Fan appears 5 times).
- **ProductName → unit price:** the price per unit is constant for each product (Egyptian Cotton Sheets 600, Cotton Towel Set 450, Smart Fan 850, Handwoven Rug 2,500, Cumin 500g 150, LED Bulb 9W 50 EGP) but it is not stored explicitly; it is hidden inside `TotalPrice_EGP`.
- Only `Quantity` (and, as a line value, `TotalPrice_EGP`) depends on the whole key (OrderID, ProductName).

### Transitive Dependencies
*(a non-key attribute depends on another non-key attribute)*
- **OrderID → ProductName → SupplierName → SupplierContact:** the supplier's phone depends on the supplier name, which in turn depends on the product, not directly on the order line (`SupplierContact` is determined by `SupplierName`: Alexandria Textiles → 010-1234-5678, Delta Electronics → 011-9876-5432, Cairo Crafts Co. → 012-3333-4444, Nile Valley Spices → 015-5555-6666).
- **OrderID → CustomerName → CustomerAddress:** the address depends on the customer, which depends on the order.
- **TotalPrice_EGP = Quantity × unit price(ProductName):** derived value; it is computed from Quantity and a product-level price rather than being an independent fact (for example Smart Fan: 1 × 850 = 850, 2 × 850 = 1,700, 3 × 850 = 2,550).

**Why this violates 2NF:**
A table is in 2NF only if it is in 1NF and every non-key attribute depends on the *whole* composite key. In the Pharos file the key is (OrderID, ProductName), but `CustomerName` and `CustomerAddress` depend only on `OrderID`, while `SupplierName` and `SupplierContact` depend only on `ProductName`. These partial dependencies are exactly what produces the repeated values and the update, insert and delete anomalies shown in Section 2, so the file fails 2NF.

---

## 4. Decomposition Steps (1NF to 2NF)

### Step 1: Transition to First Normal Form (1NF)
- **Identify the key:** (`OrderID`, `ProductName`) uniquely identifies each row; there are no duplicate rows and no NULLs.
- **Check for repeating groups and lists:** none. Each cell holds a single value (one phone number per supplier, one product per row), so no extra rows or child tables are needed.
- **Make every value atomic:** the only combined field is `CustomerAddress` (`"15 Saad Zaghloul St, Alexandria"` holds street and city together). It is split into `street_address` and `city`.
- **Result:** a 1NF table with 9 atomic columns: `OrderID`, `CustomerName`, `street_address`, `city`, `ProductName`, `SupplierName`, `SupplierContact`, `Quantity`, `TotalPrice_EGP`. It is in 1NF but still repeats data.

### Step 2: Transition to Second Normal Form (2NF)
Partial dependencies are removed by moving each attribute to the table whose key fully determines it:

1. `OrderID → customer data` → separate **Order** table (with the customer isolated in its own **Customer** table).
2. `ProductName → supplier data` → separate **Product** table (with the supplier isolated in its own **Supplier** table, which also removes the transitive dependency `ProductName → SupplierName → SupplierContact`).
3. What depends on the whole key (`OrderID` + `ProductName`) stays in the **Order_Item** junction table.

Surrogate integer keys (`customer_id`, `supplier_id`, `product_id`, `order_id`) are introduced so identifiers are compact and immutable; the original `OrderID` is kept as the unique `order_number`.

**New Entity Structures:**
- **Customer Entity:** `customer_id` (PK), `customer_name`, `street_address`, `city`
- **Supplier/Vendor Entity:** `supplier_id` (PK), `supplier_name` (unique), `supplier_contact`
- **Product Entity:** `product_id` (PK), `product_name` (unique), `unit_price_egp`, `supplier_id` (FK → Supplier)
- **Order Entity:** `order_id` (PK), `order_number` (unique, the original `OrderID`), `customer_id` (FK → Customer)
- **Order_Item (Junction) Entity:** `order_id` (PK, FK → Order), `product_id` (PK, FK → Product), `quantity`, `unit_price_egp`

**Relationships:** Customer 1–N Order; Order 1–N Order_Item; Product 1–N Order_Item (so Order ↔ Product is many-to-many); Supplier 1–N Product.

### Column Mapping: zero data loss
Every column of the original CSV maps to a place in the new tables:

| Original column | New location |
|---|---|
| `OrderID` | `orders.order_number` (the order's row is referenced from `order_items.order_id`) |
| `CustomerName` | `customers.customer_name` |
| `CustomerAddress` | `customers.street_address` + `customers.city` (split for atomicity) |
| `ProductName` | `products.product_name` |
| `SupplierName` | `suppliers.supplier_name` |
| `SupplierContact` | `suppliers.supplier_contact` |
| `Quantity` | `order_items.quantity` |
| `TotalPrice_EGP` | Calculated as `order_items.quantity × order_items.unit_price_egp` (unit price = `TotalPrice_EGP ÷ Quantity`, also held as the list price in `products.unit_price_egp`) |

**Record counts:** the 25 flat rows decompose into 7 customers, 4 suppliers, 6 products, 24 orders and 25 order items.

**Verification:** the decomposition was loaded into a PostgreSQL 16 test database and joined back together; the result matched all 25 original rows and all 8 original columns exactly (including `TotalPrice_EGP`).

*Note: Further normalization to 3NF and the definition of the Physical Model (including exact PostgreSQL data types and foreign key constraints) are mapped out in `pharos_normalized_ard.pdf` (page 3). The dbdiagram.io source is in `pharos_normalized_ard.dbml`.*
