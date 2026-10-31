# CartGrid Engineering Wiki: SQL Syntax & Style Guide

Welcome to the CartGrid database team! As a rapidly expanding e-commerce platform, our relational database handles millions of rows across `customers`, `orders`, and `products`. 

To maintain data integrity and readability, our Senior DBA, Elena Rodriguez, requires all analysts to adhere to strict SQL syntax and formatting standards. This guide covers the basics you will need for your daily reporting and data quality tasks.

---

## 1. Table Aliasing and Inner Joins

Because our data modeling separates user profiles, transactions, and inventory into distinct tables, you will constantly need to join them. At CartGrid, we require **single-letter aliases** to keep our queries clean.

An `INNER JOIN` returns only the records that have matching values in both tables. Here is the standard CartGrid formatting for combining customers and orders:

```sql
SELECT 
    C.first_name, 
    C.last_name, 
    O.order_date
FROM customers C 
INNER JOIN orders O 
    ON C.id = O.customer_id;
```

**Notice:** 
* We assign `C` to `customers` and `O` to `orders`.
* The `ON` clause explicitly defines the relationship (the primary key `id` in customers matches the foreign key `customer_id` in orders).

---

## 2. Filtering Data: The "Wear" Condition & "End" Operator

When building reports, you rarely want to see *all* the data. We use the `WHERE` clause to filter rows. 
*(Mnemonic tip from the senior team: Think of it as the "Wear Condition"—it dictates what data the final report "wears" or displays!)*

To chain multiple filters together, we use the `AND` logical operator. 
*(Another helpful mnemonic: The "End" operator, because you tack it onto the end of your first condition to narrow things down further).*

### Using Wildcards
When searching for text patterns, we use the `LIKE` operator combined with the `%` sign. The `%` sign acts as a wildcard representing zero, one, or multiple characters.

```sql
SELECT 
    P.product_name, 
    P.category
FROM products P
WHERE P.status = 'completed'
  AND P.category LIKE 'Tech%'; 
```
*In this example, `LIKE 'Tech%'` will return products in categories like 'Tech', 'Technology', 'Tech Accessories', etc.*

---

## 3. Aggregating Data (SUM, GROUP BY, and HAVING)

When the VP of Operations wants to know "How much did each customer spend?", you cannot just list individual orders. You must aggregate the data.

* **`SUM()`**: An aggregate function that adds up a numeric column (like product price).
* **`GROUP BY`**: Groups rows that have the same values in specified columns into summary rows.
* **`HAVING`**: Works exactly like a `WHERE` clause, but is used *after* aggregation to filter grouped records.

**Example: Total Sales per Customer (Over $50)**

```sql
SELECT 
    C.first_name, 
    C.last_name, 
    SUM(P.price) AS total_sales
FROM customers C
INNER JOIN orders O 
    ON C.id = O.customer_id
INNER JOIN products P 
    ON O.product_id = P.id
GROUP BY 
    C.first_name, 
    C.last_name
HAVING SUM(P.price) > 50;
```

---

## 4. Data Quality Checks (Left Joins & Orphans)

In a perfect e-commerce world, every `order` belongs to a valid `customer`. In reality, system glitches happen. Records that point to a non-existent parent record are called **"orphan records."**

Because an `INNER JOIN` only shows matching records, it will **hide** orphans. To find them, we use a `LEFT JOIN`. 

A `LEFT JOIN` returns *all* records from the left table (`orders`), and the matched records from the right table (`customers`). If there is no match, the result is `NULL` on the right side.

**Example: Finding Orphaned Orders**

```sql
SELECT 
    O.id AS order_id, 
    O.order_date, 
    O.customer_id
FROM orders O
LEFT JOIN customers C 
    ON O.customer_id = C.id
WHERE C.id IS NULL;
```

If this query returns rows, it means we have orders floating in our database with a `customer_id` that does not exist in the `customers` table. Identifying these is a critical part of a Database Analyst's job at CartGrid!