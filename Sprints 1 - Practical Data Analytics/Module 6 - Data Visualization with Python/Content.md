# Module 6: Data Visualization with Python
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** Q3 Executive Command Center – Plotly Dashboard Assembly (requested by Kwame Osei, for James Mitchell)

---

## 1. Module Summary

### 1.1 Introduction to Data Visualization
Visualization turns data into graphics that decision-makers grasp in seconds. Four principles: **simplicity, clarity, accuracy, efficiency**.
- **Chart choice:** bar/pie for categories, line/histogram for continuous data, scatter for relationships, heatmap for matrices.
- **Palettes:** sequential (ordered magnitude) vs diverging (deviation from a midpoint).
- **Mistakes:** pies with more than ~6 slices, non-zero bar baselines, too many colours, picking charts for looks.
- **Tools:** Matplotlib (control), Seaborn (statistics), Plotly (interactivity), PygWalker (drag-and-drop).

### 1.2 Matplotlib Fundamentals
`pyplot` state machine: `plot` (line), `scatter`, `bar`, `hist`, `boxplot`, `pie`. Always label with `title`, `xlabel`, `ylabel`; finish with `plt.show()` or `savefig`. Start new figures with `plt.figure()` / `subplots()`; x and y must have equal lengths.

### 1.3 Matplotlib Advanced
A **Figure** holds **Axes**. Control `figsize`, line styles, fonts, `grid`, `legend`, style sheets (`plt.style.use`), subplots (`axs[row, col]`, zero-based), `annotate`, 3-D (`projection='3d'`, `view_init`), and `savefig(dpi=300)` (default 100 dpi is blurry in print).

### 1.4 Seaborn
High-level statistical plots on DataFrames: `histplot` (+KDE), `boxplot`, `violinplot`, `countplot`, `regplot`, `pairplot`, `heatmap` (with `corr()`). Use `hue` to split by category; returns Matplotlib Axes for fine-tuning.

### 1.5 Plotly Interactive Plots
`plotly.express` (`px`) one-liners vs `graph_objects` (`go`) for detail. Built-in zoom, pan, hover, legend toggling. Customize with `hover_name`, `hover_data`, `update_xaxes(range_slider_visible=True)`; pass a DataFrame and column names; call `fig.show()` outside Jupyter.

### 1.6 Plotly Advanced
- **Dashboards:** `make_subplots(rows, cols, subplot_titles)` then `add_trace(trace, row=, col=)`; set `update_layout(title_text=...)`.
- **Animation:** `animation_frame` (time field) and `animation_group` (object identity).
- **Export:** `write_html()` keeps interactivity (embeds plotly.js); `write_image()` gives static PNG/SVG (needs kaleido). Avoid `log_x` on categorical axes.

### 1.7 Plotly Geo-Visualization
`px.choropleth` (coloured regions) and `px.scatter_geo` (bubbles) using ISO Alpha-3 `locations`; `projection` ("natural earth", "orthographic" globe); `animation_frame` for time; filter to one year for static maps.

### 1.8 PygWalker
`pyg.walk(df)` embeds a Tableau-style drag-and-drop UI in Jupyter. Treat it as read-only exploration (do wrangling in pandas first), set aggregations explicitly (sum vs mean), subsample large data, and export charts as JSON/HTML/PNG.

---

## 2. Task Overview

**Scenario:** James Mitchell (Director of Sales Strategy) needs an interactive view of regional advertising and sales performance for tomorrow's 9 AM Q3 planning meeting, presented from a tablet. Kwame supplied a starter notebook and the historical dataset.

### Deliverables (matches the expected submission tree)
```
vizionary_dashboard/
├── data/
│   └── regional_sales_data.csv
├── starter_dashboard.ipynb        (provided, unchanged)
├── dashboard_prototype.ipynb      ← deliverable
├── usability_evaluation.md        ← deliverable
├── dashboard_export.html          ← deliverable
└── README.md                      (extra: this file)
```

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | `make_subplots`, 1 row × 2 columns, titles 'Revenue by Region' and 'Ad Spend vs. Conversions' | ✅ |
| 2 | `go.Bar` in row 1, col 1: Revenue (y) by Region (x) | ✅ |
| 3 | `go.Scatter` in row 1, col 2: Ad Spend (x) vs Conversions (y), `mode='markers'` | ✅ |
| 4 | Separate cell: `px.scatter` Ad Spend vs Revenue with `animation_frame='Month'`, `size='Conversions'` | ✅ (colour = Region) |
| 5 | `dashboard_fig.write_html('dashboard_export.html')` | ✅ 4.8 MB, self-contained |
| 6 | Main title via `update_layout`, uncluttered | ✅ "Executive Command Center: Core Metrics" |
| 7 | Hover enabled on all charts | ✅ custom tooltips with exact values |
| 8 | `usability_evaluation.md`: 2–3 sentences referencing zoom, pan and hover | ✅ 3 sentences |

## 3. What the Data Shows
100 campaign rows, 4 regions (North, South, East, West), 12 months, no missing values.

| Region | Revenue | Share |
|---|---|---|
| West | $2,417,500 | 38.3% |
| South | $1,465,500 | 23.2% |
| North | $1,391,300 | 22.0% |
| East | $1,043,500 | 16.5% |
| **Total** | **$6,317,800** | |

- Ad Spend and Conversions are almost perfectly correlated (r ≈ 0.995), so the scatter panel forms a tight upward band; Ad Spend and Revenue (r ≈ 0.994) behave the same way in the animation.
- Return on ad spend (revenue ÷ spend): North 3.58, West 3.43, South 3.26, East 3.18, so East is the least efficient region.
- **Caution for month comparisons:** January has 12 rows (3 campaigns per region) while every other month has 8 (2 per region), so January totals look larger because there are more campaigns, not necessarily better performance.

## 4. How to Run
```bash
pip install pandas numpy plotly jupyter
cd vizionary_dashboard
jupyter notebook dashboard_prototype.ipynb      # Kernel → Restart & Run All
```
Run from the `vizionary_dashboard/` folder so `data/regional_sales_data.csv` resolves and `dashboard_export.html` is written next to the notebook. Open `dashboard_export.html` in any browser (no internet needed); press the ▶ button on the animated chart in the notebook to play it.

## 5. Notes and Decisions
- **Real data vs. simulated feed:** the starter notebook generates simulated data and says it "precisely mirrors" the CSV, but it does not: the CSV uses `Ad_Spend` (not `Ad Spend`), regions North/South/East/West (not North America/EMEA/APAC/LATAM), abbreviated months (Jan–Dec) and 12 months (not 6). The prototype therefore loads the real CSV, renames `Ad_Spend` to `Ad Spend`, and keeps the simulated loop only as a fallback if the file is missing.
- **Month order:** months are an ordered category so the animation runs Jan → Dec instead of alphabetically.
- **Animation axes** are fixed to the full data range so bubbles don't jump between frames.
- **Layout:** the starter's commented `width=1000` was dropped so the dashboard resizes to James's tablet screen.
- **Colour consistency:** each region has the same colour in the bar chart and the scatter panel, which keeps the dashboard readable without a legend; the region and month are in every tooltip.
- **Testing:** the notebook was executed end to end in a fresh Jupyter kernel (Plotly 7.1) and the figures were checked programmatically (subplot titles, trace types, 12 animation frames, HTML contents). I could not render screenshots here because the image exporter needs Chrome, so give the HTML a quick visual look in your browser before the meeting.
- **Sign-off:** nothing in the deliverables carries a personal name; add yours if your submission requires it.
