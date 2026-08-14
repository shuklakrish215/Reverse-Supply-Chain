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

---

## Tech Stack

| Tool | Use |
|---|---|
| **Python (Pandas)** | Merging Orders + Returns, feature engineering (`Delivery_Delay_Days`, `Return_Processing_Time`), type casting, bulk load to MySQL |
| **MySQL** | Schema design (indexed on `Category`, `Customer_ID`, `Return_Status`), window functions (`RANK() OVER`), aggregate KPI queries |
| **Power BI** | Executive dashboard — return rate trends, cost impact, disposition split |

---

## Key Business Insights ("So What?")

> Replace the bracketed values below with your actual output once
> `queries_mysql.sql` runs against your extracted Global Superstore data.

- **Financial Bleed:** Returns accounted for **[X]%** of gross revenue,
  totaling **$[Y]** in lost sales — concentrated in [top category].
- **Category Risk:** **[Category name]** has the highest return rate at
  **[X]%**, more than [N]x the rate of the lowest-risk category.
- **Logistics Impact:** Late deliveries increased return likelihood from
  **[X]%** to **[Y]%** — a direct, measurable link between fulfillment
  speed and reverse-logistics cost.
- **Customer Behavior:** Flagged **[N]** "serial returner" accounts
  (>40% return rate on 5+ orders), surfacing a candidate policy review
  (return windows, restocking fees) to cut avoidable cost.
- **Processing Efficiency:** Return processing time varies by reason —
  **[Reason]** takes **[X] days** on average vs. **[Y] days** for
  **[other reason]**, pointing to a specific inspection/grading bottleneck.

---

## Root Cause Analysis — Recommendations

| Finding | Recommendation |
|---|---|
| [Category] drives the highest return rate | Review size charts / product descriptions / QC for that category's top return reasons |
| Late delivery nearly doubles return rate | Prioritize on-time delivery for high-risk categories; consider regional fulfillment centers |
| [N] serial returners identified | Introduce return-frequency-based policy tiers (restocking fee, tightened window) |
| [Reason] returns take longest to process | Streamline inspection workflow for that return type |

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

**Return reasons by city — window function:**
```sql
SELECT City, Return_Reason, reason_count
FROM (
    SELECT
        City, Return_Reason, COUNT(*) AS reason_count,
        RANK() OVER (PARTITION BY City ORDER BY COUNT(*) DESC) AS rnk
    FROM orders_returns
    WHERE Return_Status = 'Yes'
    GROUP BY City, Return_Reason
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
├── schema.sql            # MySQL table creation (indexed, typed)
├── preprocess_mysql.py   # Pandas merge + feature engineering + MySQL load
├── queries_mysql.sql     # All 7 RCA/KPI business questions
└── README.md
```

*Raw CSVs are not included — see [Global Superstore on Kaggle](https://www.kaggle.com/datasets)
for the source data. Data structure: `Orders` (order/customer/product/sales
detail) left-joined to `Returns` (order-level return flag + reason) on
`Order_ID`.*

---

## How to Run

1. `mysql -u root -p < schema.sql`
2. Update `DB_CONFIG` in `preprocess_mysql.py` with your MySQL credentials
3. `pip install pandas pymysql sqlalchemy`
4. `python3 preprocess_mysql.py`
5. `mysql -u <user> -p returns_project < queries_mysql.sql`
