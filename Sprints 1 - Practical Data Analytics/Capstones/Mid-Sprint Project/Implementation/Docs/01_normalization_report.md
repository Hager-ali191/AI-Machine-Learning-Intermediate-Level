# Normalization Report: Legacy Billing Table
**Client:** Nexus Commerce Solutions  ·  **Requested by:** Elena Rostova, VP of Product
**Subject:** `legacy_subscriptions.csv` (50 rows, 8 columns)  ·  **Audience:** Product and executive stakeholders

---

## 1. Executive Summary

Nexus Commerce keeps every subscriber, plan and invoice fact in **one flat table**. Each invoice row repeats the customer's name and email, the plan's name and the plan's price. In the sample alone, the same Growth-plan price appears on 20 rows and a single customer's email on up to 6 rows. This repetition creates three kinds of failure (update, insert and delete anomalies), and it has already left visible damage in the data: a misspelled plan name ("Growht"), a test account, and a $0.00 test invoice.

**Recommendation:** split the table into three normalized tables, **Plans**, **Users** and **Invoices**, so each fact is stored exactly once. The migrated design has been built and tested in PostgreSQL, loads all 50 legacy rows with no data loss, and is ready for deployment review.

## 2. The Legacy Structure

| Column | Meaning |
|---|---|
| `record_id` | Row number in the legacy table |
| `user_name`, `user_email` | The subscriber |
| `plan_name`, `plan_price` | The subscriber's plan and its price |
| `invoice_id`, `invoice_date`, `invoice_amount` | The invoice |

| Fact in the sample | Value |
|---|---|
| Distinct subscribers / plan names / invoices | 11 / 4 / 50 |
| Rows repeating the same subscriber | 2–6 rows per person |
| Rows showing a $99.00 plan price | 20 (18 "Growth" + 2 "Growht") |

## 3. Anomalies in the Legacy Design

### 3.1 Update anomaly: changing a plan's price
**Scenario:** Nexus raises the Growth plan from $99 to $119.
**Problem:** the price is stored on every invoice row of every Growth subscriber, so **18 rows** must be edited (and the 2 rows spelled "Growht" are easily missed because they look like a different plan). Any row missed leaves two prices for the same plan, and financial reports no longer agree. At production scale, the brief's "thousands of redundant rows" is the same risk.
**Resolved by:** the price lives once in `plans.monthly_price`, so one row is updated.

### 3.2 Insert anomaly: adding a plan or a subscriber before the first invoice
**Scenario:** Product wants to launch a new "Scale" plan at $199, or register a customer who has not been billed yet.
**Problem:** a row only exists when there is an invoice (`invoice_id`, `invoice_date` and `invoice_amount` are filled on every row), so a plan or a user cannot be recorded until an invoice exists, and inventing a fake invoice would corrupt revenue figures. This is why the legacy table cannot contain any inactive user at all.
**Resolved by:** plans and users have their own tables and can exist without invoices.

### 3.3 Delete anomaly: removing an invoice erases a customer
**Scenario:** the three invoices of Mia Robinson (Growth plan) are voided or deleted.
**Problem:** those three rows are the *only* place her name, email and plan are recorded, so deleting the invoices also deletes the customer. Likewise, deleting the two "Test User" rows removes the only record of the "Growht" plan.
**Resolved by:** deleting an invoice removes only the invoice row; the user and plan remain.

### Data-quality issues already present
| Issue | Rows | Effect |
|---|---|---|
| Plan name typo "Growht" (should be "Growth") | 2 (record 15 and 40) | The plan appears as a separate plan in reports |
| "Test User" account (test@nexuscommerce.com) | 2 | Test data mixed with real revenue |
| Invoice INV-9999 with amount $0.00 | 1 | Invalid invoice |

## 4. Decomposition Strategy (1NF → 2NF → 3NF/BCNF)

### Step 1: First Normal Form (1NF): atomic data
- Every column already holds a single, atomic value: no lists, no repeating columns. Names, emails, dates and amounts are single values and dates use one format.
- Each row is identified by a key: `record_id` (the legacy row number), and `invoice_id` is also unique in the sample.
- **Result:** the table is in 1NF. No restructuring is needed here, but the repetition remains.

### Step 2: Second Normal Form (2NF): separate facts that depend on only part of the key
- A row is one invoice for one subscriber's plan, so the business key is *(subscriber, invoice)*. Subscriber and plan facts (`user_name`, `plan_name`, `plan_price`) depend only on the **subscriber**, not on the whole key: a partial dependency. Only `invoice_date` and `invoice_amount` depend on the whole invoice.
- **Action:** move subscriber and plan facts out of the invoice row. Create:
  - **Invoices**: one row per invoice (the facts that belong to the invoice itself)
  - **Users**: one row per subscriber (name, email)
  - **Plans**: one row per plan (name, price)
- **Result:** every non-key column now depends on the key of its own table.

### Step 3: Third Normal Form / BCNF: remove dependencies between non-key columns
- In the legacy data `user_email → plan_name → plan_price`: the price depends on the plan, not on the user. Keeping price on the user would still repeat it for every Growth subscriber.
- **Action:** keep the price in **Plans** and link users to it with a foreign key `users.plan_id`. Link invoices to users with `invoices.user_id`.
- **BCNF check:** in `plans`, `users` and `invoices`, every determinant is a key (`plan_id`, `user_id`/`email`, `invoice_id`/`invoice_number`). One exception to resolve: `plans.plan_name` should be unique, because `plan_name → monthly_price`. It is not enforced yet (see Section 7), because the misspelled duplicate "Growht" plan still exists.

### Column mapping: zero data loss
| Legacy column | New location |
|---|---|
| `record_id` | Not carried over (a row counter); replaced by `invoices.invoice_id` (SERIAL) |
| `user_name` | `users.username` |
| `user_email` | `users.email` (UNIQUE) |
| `plan_name` | `plans.plan_name` |
| `plan_price` | `plans.monthly_price` |
| `invoice_id` (e.g. INV-1001) | `invoices.invoice_number` (UNIQUE) |
| `invoice_date` | `invoices.invoice_date` |
| `invoice_amount` | `invoices.amount` (price actually charged) |

**Verification:** the 50 legacy rows were loaded into the new tables (4 plans, 11 users, 50 invoices) and a three-table join rebuilt the original data exactly (all 50 rows, all 7 data columns).

## 5. The Normalized Design

```
plans (1) ──< users (1) ──< invoices
```
| Table | Primary key (SERIAL) | Foreign key | Other columns |
|---|---|---|---|
| `plans` | `plan_id` | – | `plan_name` NOT NULL, `monthly_price` NOT NULL |
| `users` | `user_id` | `plan_id` → plans | `username` NOT NULL, `email` NOT NULL UNIQUE |
| `invoices` | `invoice_id` | `user_id` → users | `invoice_number` UNIQUE, `invoice_date`, `amount`, `discount_code` |

The visual ERD is in `02_normalized_erd.pdf`.

## 6. Migration Plan (simulated ALTER TABLE changes)
| Change | Statement | Risk |
|---|---|---|
| New optional discount field on invoices | `ALTER TABLE invoices ADD COLUMN discount_code VARCHAR(30)` | Low; existing rows get NULL |
| Longer usernames | `ALTER TABLE users ALTER COLUMN username TYPE VARCHAR(100)` | Low; widening never truncates |
| Remove deprecated notes | `ALTER TABLE users DROP COLUMN legacy_notes` | **Irreversible:** back up first |

## 7. Business Impact and Next Steps
- **One price update instead of many:** plan prices are changed in a single row, eliminating inconsistent pricing.
- **Customers and plans exist independently of invoices:** onboarding and plan launches no longer require fake invoices.
- **Cleaner reporting:** revenue per plan and per customer can be calculated with simple joins (see `04_reports.sql`).

Recommended follow-ups:
1. **Consolidate the "Growht" plan.** After the targeted spelling fix in `04_reports.sql`, the Test User still points to its own plan row, which now duplicates "Growth". Repoint that user to the Growth plan, delete the duplicate row, and then add `UNIQUE (plan_name)` to reach full BCNF.
2. **Review the remaining test data:** the Test User account and its $99.00 invoice (INV-9998) are still counted in revenue after the cleanup.
3. **Track plan changes over time.** Users hold one current plan; if customers can switch plans, add a subscriptions history table.
4. **Back up before dropping `legacy_notes`** and before any production migration.
