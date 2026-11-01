# Module 5: Data Analysis with Python
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** Apex Financial Summary Pipeline Rewrite (requested by Dr. Amina Diop)

---

## 1. Module Summary

### 1.1 Introduction to NumPy
NumPy's `ndarray` is a contiguous, single-dtype, N-dimensional array with vectorized operations written in C. Import as `np`.
- **Inspect:** `.ndim`, `.shape`, `.size`, `.dtype`. A 1-D array has shape `(n,)`.
- **Vectorization:** whole-array math with no Python loops. **Broadcasting:** lets arrays of compatible shapes combine.
- **axis:** `matrix.sum(axis=0)` sums columns, `axis=1` sums rows.
- Mistakes: expecting mixed types in one array, looping instead of vectorizing.

### 1.2 NumPy Fundamentals
- **Creation:** `zeros`, `ones`, `arange`, `linspace`, random generators, `loadtxt`/`load`.
- **Slicing returns a view** (changes affect the original); use `.copy()` for an independent array. Fancy indexing returns a copy.
- **Boolean masks:** `data[data > 3] = 10`. **Casting:** `astype`. **Reproducibility:** `np.random.seed(n)`.

### 1.3 Linear Algebra with NumPy
- Matrix product: `A @ B` or `np.dot` (not `*`, which is element-wise). Transpose: `A.T`.
- `np.linalg.det`, `inv`, `eig`, and `solve(A, b)` for Ax = b; verify with `np.allclose(A @ x, b)`.
- A singular matrix (det = 0) cannot be inverted or solved. ufuncs (`np.sqrt`, `np.exp`) work element-wise.

### 1.4 Advanced NumPy
- **Reshape:** `reshape` (view), `ravel` (view if possible), `flatten` (always a copy).
- **Stack / split:** `vstack`, `hstack`, `dstack`; `split`, `vsplit`, `hsplit`.
- **Indexing:** fancy (`a[[2,5,3]]`) and boolean (`a[a % 2 == 0]`).

### 1.5 Introduction to Pandas
`Series` (labelled 1-D) and `DataFrame` (2-D, built from Series, mixed dtypes). Load with `pd.read_csv()` (also `read_excel`, `read_json`, `read_sql`); inspect with `head()`, `tail()`, `info()`, `describe()`; export with `to_csv(index=False)`. Use `nrows=` / `chunksize=` for large files.

### 1.6 Data Manipulation with Pandas
- **Selection:** `df['col']`, `df[['a','b']]`, `loc` (labels, inclusive), `iloc` (positions, end-exclusive).
- **Missing data:** `isnull()`, `fillna()`, `dropna()` (check the share of missing values before dropping).
- **Reshaping:** `pivot`, `stack`, `unstack`.

### 1.7 Pandas for Analysis
Split-apply-combine: `df.groupby(keys)` then `.sum()`, `.mean()` or `.agg({'col': ['sum','mean']})`; `.reset_index()` to turn group keys back into columns; `sort_values()`, `.T`; `pd.to_datetime` plus a DateTime index for time series.

### 1.8 Advanced Pandas
Think in arrays, not loops: vectorized math and `np.where(mask, a, b)` for conditional columns, one-hot encoding with `get_dummies`, and Polars for data larger than memory. Vectorized code is often 10–100× faster than Python loops.

---

## 2. Task Overview

**Scenario:** Apex Financial's legacy summary script uses Python `for`-loops and times out / crashes local memory. The task is to rewrite it as a strictly vectorized Pandas and NumPy pipeline.

### Deliverables (matches the expected submission tree)
```
nexus_project/
├── data/
│   └── transactions.csv
├── pipeline.ipynb
├── output/
│   ├── executive_summary.csv
│   └── reply_draft.txt
└── README.md          (extra: this file)
```

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | Load `transactions.csv` into `df` with `pd.read_csv()` | ✅ 30 rows × 5 columns |
| 2 | `transaction_category` using exactly `np.where(df['amount'] > 5000, 'High', 'Standard')` | ✅ 13 High / 17 Standard |
| 3 | `scaled_amount = df['amount'] * 0.01` (broadcasting, no loop) | ✅ |
| 4 | `df.groupby('region').agg({'amount': ['sum', 'mean']})` as `summary_df` | ✅ |
| 5 | Export to `output/executive_summary.csv` with `.to_csv()` | ✅ |
| 6 | Markdown cell at the bottom: 1–2 sentences defining vectorization and why it beats a `for`-loop | ✅ |
| 7 | No explicit `for` / `while` loops anywhere in the code | ✅ checked programmatically |
| 8 | No `SettingWithCopyWarning` or other pandas warnings | ✅ ran with warnings treated as errors |
| 9 | CSV shows the multi-level headers from `.agg()` | ✅ |
| 10 | Reply email to Dr. Diop with the explanation | ✅ `output/reply_draft.txt` |

## 3. Results

| Region | Total amount | Mean amount |
|---|---|---|
| East | 21,434.50 | 2,679.31 |
| North | 30,081.75 | 3,760.22 |
| South | 24,063.69 | 3,437.67 |
| West | 34,187.80 | 4,883.97 |

Grand total: **$109,767.74** across 30 transactions (the total of the four regions matches the raw data exactly). 13 transactions exceed 5,000, led by the largest, TXN-58413 (North, $9,821.50). West has both the highest total and the highest average.

`executive_summary.csv` begins with the two-level header that `.agg()` produces:
```
,amount,amount
,sum,mean
region,,
East,21434.5,2679.3125
...
```
To read it back with both header levels: `pd.read_csv('output/executive_summary.csv', header=[0, 1], index_col=0)`.

## 4. How to Run
```bash
pip install pandas numpy jupyter
cd nexus_project
jupyter notebook pipeline.ipynb      # then Kernel → Restart & Run All
```
Run it from the `nexus_project/` folder so the relative paths `data/transactions.csv` and `output/` resolve.

## 5. Notes
- **Paths:** the starter notebook said `transactions.csv`; I read it from `data/transactions.csv` to match the expected tree. The `output/` folder must exist before export (it is included).
- **Values not rounded:** the CSV keeps full precision (e.g. South mean 3437.6699999999996 is floating-point noise). Round with `.round(2)` before exporting if the client prefers; the task didn't ask for it.
- **Starter text preserved:** the notebook keeps the starter's titles and step headings; the `TODO` cells are now implemented, and I added a few inspection cells (`df.info()`, category counts) that contain no loops.
- **Edge case:** `amount > 5000` is strict, so an amount of exactly 5000.00 is "Standard" (none in this data).
- **Environment:** the notebook was executed end to end in a fresh Jupyter kernel (pandas 3.0, NumPy 2.4) before saving, so outputs are stored in the file.
- **Sign-off:** the reply is signed "Nexus Analytics Group - Financial Modeling"; add your name if you wish.
