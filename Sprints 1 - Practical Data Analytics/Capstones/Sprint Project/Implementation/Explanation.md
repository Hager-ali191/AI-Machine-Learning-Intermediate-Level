# Data Foundations Sprint Project: GlobalMart Q4 Sales Dashboard
**LuminaMetrics · Client: GlobalMart · Requested by Elena Rostova, VP of Client Strategy**
**AI & Machine Learning – Intermediate Level · Sprint 1 (Practical Data Analytics) capstone**

---

## 1. Project Overview

GlobalMart, an international retail chain, wants to understand Q4 sales across regions and product categories so it can allocate inventory for next quarter. Their raw extract fails to load cleanly in our pipelines: `Revenue` is stored as text with currency symbols, and the data contains invalid records (zero and negative quantities). Their executives also cannot read raw tables, so they need an interactive, code-free way to explore the data.

**Goal:** deliver a verified, cleaned dataset and a self-contained interactive dashboard, built entirely in a secure Python and Jupyter environment (Pandas, NumPy, Matplotlib, Plotly), with no external databases and no BI tools.

## 2. Deliverables

```
deliverables/
├── data/
│   └── q4_sales_data.csv                      (raw client extract, unchanged)
├── notebooks/
│   └── data_debugging_dashboard.ipynb         ← completed notebook (executed, outputs saved)
├── output/
│   └── dashboard.html                         ← interactive Plotly scatter plot (self-contained, ~4.8 MB)
└── README.md                                  (this file)
```

## 3. The Data

| Item | Value |
|---|---|
| Rows × columns | 500 × 6 |
| Columns | `Transaction_ID`, `Date`, `Region`, `Product_Category`, `Quantity`, `Revenue` |
| Period | 2023-10-01 to 2023-12-31 (Q4) |
| Regions | North America, Europe, Asia-Pacific, Latin America, Middle East (100 rows each) |
| Categories | Electronics, Apparel, Home & Garden, Sports, Toys (100 rows each) |
| Missing values / duplicates | none |

**Anomalies found**
1. **Mixed datatypes:** `Revenue` is a string (`$599.98`, `-$299.99`), so it cannot be summed or plotted.
2. **Invalid records:** 113 of 500 rows (22.6%) have `Quantity <= 0`: 75 negative (returns or system errors, with negative revenue) and 38 zero (with `$0.00` revenue).

## 4. Method (Step by Step)

| Step | What the notebook does | Result |
|---|---|---|
| 1. Load and inspect | `pd.read_csv`, then `.shape` and `.dtypes` | `(500, 6)`; `Revenue` is a string |
| 2. Fix datatype | `.str.replace('$', '')`, `.str.replace(',', '')`, `.astype(float)` | `Revenue` becomes `float64`, no NaN created; negative signs preserved (`-$299.99` → `-299.99`) |
| 3. Boolean mask | `np.greater(Quantity, 0)` → `cleaned_sales` | `(387, 6)`; **0** rows with `Quantity <= 0` (asserted in code) |
| 4. Strategy brief | Markdown: bar chart for categorical `Region`, histogram for continuous `Revenue` | Written in the notebook |
| 5a. Static chart | Matplotlib bar chart of total sales by region | Title, axis labels, `$` tick labels, visible ticks |
| 5b. Interactive chart | Plotly Express scatter, `Quantity` vs `Revenue`, hover shows `Product_Category` | Exported to `output/dashboard.html` |

Design choices:
- `regex=False` in `.str.replace` because `$` is a special character in regular expressions.
- `cleaned_sales` is created with `.copy()` so there are no `SettingWithCopy` warnings.
- The scatter plot is coloured by product category, so executives can click the legend to isolate a category, and its tooltips also show `Region`, `Quantity` and the exact revenue.
- Both charts are kept uncluttered: descriptive titles, labeled axes, clear tick marks, light gridlines, and a white background for the interactive chart.
- Every code cell is preceded by a Markdown cell describing its logic and expected output (an acceptance criterion).

## 5. Results

| Metric | Value |
|---|---|
| Valid transactions | 387 |
| Revenue before cleaning | $58,731.62 |
| Revenue of the 113 invalid rows | -$6,459.97 |
| **Revenue after cleaning** | **$65,191.59** |

| Region | Total sales | Share |
|---|---|---|
| North America | $31,949.97 | 49.0% |
| Latin America | $12,616.25 | 19.4% |
| Asia-Pacific | $10,335.00 | 15.9% |
| Europe | $5,500.00 | 8.4% |
| Middle East | $4,790.37 | 7.3% |

Observations:
- North America generates about half of all valid revenue, so inventory planning should prioritize it.
- The scatter plot shows the strips at Quantity 1–6 (6 is rare, only 2 transactions); Electronics reaches the highest revenue per transaction (unit prices from $150 to $1,200).
- Middle East has the most invalid records (31 vs about 20 elsewhere), which is worth raising with GlobalMart's data team.

**Important caveats for the client conversation**
- **Region and category are fully overlapped in this extract:** each region sells exactly one product category (North America = Electronics, Latin America = Sports, Asia-Pacific = Home & Garden, Europe = Apparel, Middle East = Toys). The "regional" differences cannot be separated from category differences, so recommendations should not treat them as independent.
- **Cleaned revenue is gross sales:** removing negative-quantity rows also removes returns, so the $65,191.59 is not net of returns.

## 6. Acceptance Criteria Check

| Criterion | Status |
|---|---|
| Notebook executes top to bottom without errors | ✅ executed end to end in a fresh Jupyter kernel |
| `cleaned_sales` has exactly 0 rows with `Quantity <= 0` | ✅ asserted in the notebook |
| Every code cell is immediately preceded by a Markdown cell explaining logic and expected output | ✅ checked programmatically |
| Charts have descriptive titles, labeled axes and clear tick marks, with no clutter | ✅ |
| `Revenue` is `float64` | ✅ |
| Bar chart (Matplotlib) with title, X label, Y label | ✅ |
| Scatter plot with hover tooltips showing `Product_Category` | ✅ |
| `dashboard.html` exported | ✅ |

## 7. How to Run
```bash
pip install pandas numpy matplotlib plotly jupyter
cd deliverables/notebooks
jupyter notebook data_debugging_dashboard.ipynb      # Kernel → Restart & Run All
```
Run from the `notebooks/` folder because paths are relative (`../data/q4_sales_data.csv`, `../output/dashboard.html`). To present, open `output/dashboard.html` in any browser (no internet or Python needed).

## 8. Notes
- The starter notebook loaded `'q4_sales_data.csv'` from the current folder; paths were changed to match the required submission tree.
- I verified the bar chart visually and checked the Plotly figure's structure (titles, axis labels, hover template, 5 category traces). I could not take a screenshot of `dashboard.html` here (the image exporter needs Chrome), so open it once in a browser before the board meeting.
- Technologies used: Python, Jupyter, NumPy, Pandas, Matplotlib, Plotly.
