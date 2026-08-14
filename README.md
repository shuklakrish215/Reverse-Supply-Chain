# Reverse-Supply-Chain
# E-Commerce Returns Optimization & Supply Chain Root Cause Analysis

## Executive Summary

**The Problem:** The company was experiencing high return rates across product
categories, driving revenue bleed and reverse-logistics bottlenecks in the
returns/fulfillment pipeline.

**The Solution:** Built a Python + MySQL data pipeline to clean and merge
historical order and returns data, engineer delivery/processing-time
features, quantify the exact financial impact, and run a Root Cause
Analysis (RCA) identifying *why* returns were happening — by category,
customer, city, and delivery performance — with recommendations tied to
each finding.

**Data source:** [Global Superstore Dataset](https://www.kaggle.com/datasets) (Kaggle) —
Orders and Returns tables, ~[N] orders / ~[N] returns after cleaning.



## Tech Stack

| Tool | Use |
|---|---|
| **Python (Pandas)** | Merging Orders + Returns, feature engineering (`Delivery_Delay_Days`, `Return_Processing_Time`), type casting, bulk load to MySQL |
| **MySQL** | Schema design (indexed on `Category`, `Customer_ID`, `Return_Status`), window functions (`RANK() OVER`), aggregate KPI queries |

---

## Key Business Insights ("So What?")

- **Financial Bleed:** Returns accounted for **12.79%** of gross revenue
  (**$1,212,332.99** gross sales), totaling **$155,069.02** in lost sales
  — an overall return rate of **14.65%** across 2,000 orders.
- **Category Risk:** **Technology** has the highest return rate at
  **18.61%** (115 of 618 orders), vs. **13.66%** for Office Supplies and
  **10.82%** for Furniture — nearly double the lowest-risk category.
- **Logistics Impact:** Late deliveries raise return likelihood from
  **11.96%** (on-time) to **22.66%** (late) — a direct, measurable link
  between fulfillment speed and reverse-logistics cost.
- **Customer Behavior:** Flagged **13** "serial returner" accounts
  (>40% return rate on 5+ orders) — the top account returned 80% of its
  orders — surfacing a candidate policy review (return windows, restocking
  fees) to cut avoidable cost.
- **Regional Patterns:** Return reasons vary by region — **Wrong Size**
  dominates in the East (27 cases), while **Damaged in Transit** is the
  top reason in the South, West, and Central regions, pointing to a
  packaging/carrier issue outside the East.

---

## Root Cause Analysis — Recommendations

| Finding | Recommendation |
|---|---|
| Technology drives the highest return rate (18.61%) | Review product descriptions / QC and packaging for Technology SKUs |
| Late delivery nearly doubles return rate (11.96% → 22.66%) | Prioritize on-time delivery for high-risk categories; consider regional fulfillment centers |
| 13 serial returners identified (up to 80% return rate) | Introduce return-frequency-based policy tiers (restocking fee, tightened window) |
| Damaged in Transit dominates outside the East | Audit packaging/carrier handling for South, West, Central regions |

---

## Sample Queries

**Category risk — return rate by product category:**
```sql
SELECT
    Category,
    COUNT(*) AS total_orders,
    SUM(Return_Status = 'Yes') AS total_returns,
    ROUND(100.0 * SUM(Return_Status = 'Yes') / COUNT(*), 2) AS return_rate_pct
FROM orders_returns
GROUP BY Category
ORDER BY return_rate_pct DESC
LIMIT 3;
```

**Top return reason by region — window function:**
```sql
SELECT Region, Return_Reason, reason_count
FROM (
    SELECT
        Region, Return_Reason, COUNT(*) AS reason_count,
        RANK() OVER (PARTITION BY Region ORDER BY COUNT(*) DESC) AS rnk
    FROM orders_returns
    WHERE Return_Status = 'Yes'
    GROUP BY Region, Return_Reason
) ranked
WHERE rnk = 1
ORDER BY reason_count DESC;
```

**Serial returners — customers abusing return policy:**
```sql
SELECT
    Customer_ID,
    COUNT(*) AS total_orders,
    SUM(Return_Status = 'Yes') AS total_returns,
    ROUND(100.0 * SUM(Return_Status = 'Yes') / COUNT(*), 2) AS return_rate_pct
FROM orders_returns
GROUP BY Customer_ID
HAVING COUNT(*) >= 5 AND return_rate_pct > 40
ORDER BY return_rate_pct DESC;
```

---

## Repository Structure

```
├── schema.sql              # MySQL table creation (indexed, typed)
├── preprocess_mysql.py     # Pandas merge + feature engineering + MySQL load
├── generate_sample_data.py # Synthetic data generator (schema-matched, realistic distributions)
├── Problems.sql             # All RCA/KPI business questions
└── README.md
```

---

## How to Run

1. `mysql -u root -p < schema.sql`
2. Update `DB_CONFIG` in `preprocess_mysql.py` with your MySQL credentials
3. `pip install pandas pymysql sqlalchemy`
4. `python3 generate_sample_data.py` (or point the script at your own Orders/Returns CSVs)
5. `python3 preprocess_mysql.py`
6. `mysql -u <user> -p returns_project < Problems.sql`
