# Module 1: Introduction to Data Science
**Sprint 1 – Practical Data Analytics · AI & Machine Learning (Intermediate Level)**
**Task:** Pitching a Recommendation Engine using the Data Science Process

---

## 1. Module Summary

### 1.1 Data Science Concepts
Data science extracts insight and predictions from structured and unstructured data by combining **mathematics & statistics**, **computer science**, and **domain expertise**.

| Term | Meaning |
|---|---|
| Machine Learning | Algorithms that learn patterns from data without a hand-written rule for each case |
| Recommendation Engine | Predicts user preferences and suggests items (movies, products) from past behaviour and similarity |
| Predictive Analytics | Using historical data to forecast future events |
| Structured vs. Unstructured | Tabular data with a fixed schema vs. text, images, audio |
| Domain Expertise | Knowledge of the business area, needed to frame questions and validate results |

**Common mistakes:** ignoring business context, skipping data-quality checks, equating high accuracy with business value.
**Real-world example:** a streaming service personalising its homepage with collaborative filtering (higher watch time, lower churn).

### 1.2 Specializations in Data Science
| Role | Focus |
|---|---|
| Data Engineer | Builds and maintains data pipelines |
| Data Scientist | Statistical analysis and ML to find insight |
| ML Engineer | Deploys and monitors models in production |
| NLP Engineer | Models that understand or generate human language |
| Data Analyst | Cleans, explores and visualises data for business questions (BI tools such as Tableau, Power BI) |

Key points: a single project cycles through every role, not all roles need deep ML, and analysts (descriptive) differ from scientists (predictive).

### 1.3 The Data Science Process (7 canonical steps)
1. **Problem Definition**: turn the business question into a precise, data-driven objective
2. **Data Collection**: gather structured and unstructured data into one dataset
3. **Data Cleaning & Preparation**: fix formats, missing values, outliers, duplicates; ensure privacy compliance
4. **Exploratory Data Analysis (EDA)**: visualise distributions and relationships; spot anomalies and features
5. **Model Selection & Training**: pick suitable algorithms and fit them to the data
6. **Model Evaluation & Tuning**: measure accuracy, precision, recall, F1; tune hyperparameters
7. **Deployment & Monitoring**: expose via APIs/services, monitor, retrain as data drifts

Quick facts: cleaning takes 60–80% of project time; EDA originates with John Tukey (1970s); deployment failure is a top reason projects never create value.
Mistakes to avoid: modelling without a clear question, ignoring outliers, evaluating on training data (use train-test split / cross-validation), "deploy and forget".

### 1.4 Use Cases & Data-Driven Decision-Making (DDDM)
DDDM is the disciplined use of data and analysis to guide and justify business actions. The flow adds **feature engineering**, **A/B testing**, and **communication** (dashboards, plain-language reports) to the process above. Key tools: **SQL** (retrieve and join data), **Python/pandas** (clean, analyse, model), **Tableau/Power BI** (dashboards). Precision and recall often trade off. Example: an Amazon recommender overhaul validated by A/B testing (7% lift in average order value).

### 1.5 Careers in Data Science
Entry paths: Computer Science, Statistics/Math, IT, Engineering. Core stack: **Python, R, SQL**, pandas, NumPy, scikit-learn, TensorFlow, and Hadoop/Spark for scale. Soft skills (communication, problem solving, collaboration, adaptability) are as important as algorithms. Mistakes to avoid: relying on one language, neglecting soft skills, reinventing algorithms, staying in one industry silo.

---

## 2. Task Overview

**Scenario:** Raj asked for a first-draft executive summary, formatted as an email pitch, to Amira Al-Fayed. She needs to secure Q3 budget for upgrading **OmniStream Media's** content recommendation engine, and she is not a technical expert. The pitch must demystify how the data science works.

**Technologies:** Markdown, CSV/Excel, sample CSV data.

### Deliverables
| File | Description |
|---|---|
| `recommendation_pitch_summary.md` | Executive summary formatted as an email pitch, following the provided template |
| `tool_stage_mapping.csv` | Table with columns `Stage`, `Tool`, `Function` mapping SQL, Python, Excel, Tableau to the 7 stages |
| `README.md` | This document |

### Requirements Checklist
| # | Requirement | Status |
|---|---|---|
| 1 | Pitch addressed to Amira Al-Fayed, based on the template | ✅ |
| 2 | Netflix analogy, max 150 words, uses the exact term "historical data" | ✅ 132 words |
| 3 | 7 canonical steps in order, exactly one sentence each | ✅ verified programmatically |
| 4 | Vocabulary used correctly in the pitch: `pipeline`, `EDA`, `outliers`, `stakeholders` | ✅ all in Section 2 |
| 5 | `tool_stage_mapping.csv` with `Stage`, `Tool`, `Function` | ✅ 18 rows, 7 stages, 4 tools |
| 6 | Professional, accessible tone for non-technical readers | ✅ |
| 7 | Template structure and all section headers retained | ✅ |

---

## 3. Sample Data Reference

`historical_viewing_sample.csv` (30 records; the two uploaded copies are identical) shows what raw inputs look like.

| Column | Description |
|---|---|
| `User_ID` | Subscriber identifier |
| `Content_ID` | Title identifier |
| `Genre` | Sci-Fi, Comedy, Drama, Documentary, Action, Romance, Thriller |
| `Watch_Duration_Minutes` | Minutes watched (12–140) |
| `User_Rating` | 1.5–5.0 |

Quick profile: 9 users, 9 titles, 7 genres, no missing values or duplicates; mean rating ≈ 3.9, mean watch time ≈ 81 min. Comedy titles are short (~25 min) while Drama and Action average 105+ min. A few records with very short watch time and low rating (e.g. 12–15 minutes at 1.5–2.0) illustrate the **outliers** discussed in Step 3 of the pitch. The data informed the pitch's examples only; it is not reproduced in the pitch itself.

---

## 4. Design Decisions

- **Analogy:** Netflix-style, focused on watch time, ratings and similar viewers, with "historical data" used explicitly.
- **Workflow:** one sentence per step, business-outcome wording instead of technical jargon. The required terms are placed naturally: *stakeholders* (Step 1), *pipeline* (Step 2), *outliers* (Step 3), *EDA* (Step 4).
- **Tool mapping:** each stage has at least one tool, and every tool appears in several stages: SQL (extract, clean, store), Python (clean, explore, model, deploy), Excel (baselines, spot checks, comparisons), Tableau (dashboards for communication).
- **Template:** the instruction note from Raj and the bracketed placeholders were removed; all other headers were kept.

## 5. Things to Review Before Sending

- **Sender name/title:** set generically as "Data Science Analyst, Analytics Team". Replace with your own name.
- **Amira's title:** "Product Lead" is an assumption; the brief does not state it. Please confirm.
- No performance figures (e.g. % lift) were claimed, because none were provided for OmniStream.

## 6. Final Structure

```
.
├── README.md
├── recommendation_pitch_summary.md
└── tool_stage_mapping.csv
```
