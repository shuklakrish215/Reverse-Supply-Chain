USE returns_project;

-- Check total orders, total returns, and the overall return rate
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) AS total_returns,
    ROUND(100.0 * SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS overall_return_rate_pct
FROM orders_returns;

-- Check overall gross sales and profit
SELECT 
    ROUND(SUM(Sales), 2) AS total_gross_sales,
    ROUND(SUM(Profit), 2) AS total_gross_profit
FROM orders_returns;

-- Calculate the exact revenue lost to returns and its percentage against gross sales.
SELECT
    ROUND(SUM(CASE WHEN Return_Status = 'Yes' THEN Refund_Amount ELSE 0 END), 2) AS total_revenue_lost,
    ROUND(SUM(Sales), 2) AS gross_revenue,
    ROUND(
        100.0 * SUM(CASE WHEN Return_Status = 'Yes' THEN Refund_Amount ELSE 0 END) / SUM(Sales), 2
    ) AS pct_of_gross_revenue_lost
FROM orders_returns;

-- Identify the top 3 most problematic product categories by return rate.

SELECT
    Category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) AS total_returns,
    ROUND(100.0 * SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS return_rate_pct
FROM orders_returns
GROUP BY Category
ORDER BY return_rate_pct DESC
LIMIT 3;

-- Flag "high-risk" customers who abuse the return policy (minimum of 5 orders, returning over 40% of them).

SELECT
    Customer_ID,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) AS total_returns,
    ROUND(100.0 * SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS return_rate_pct
FROM orders_returns
GROUP BY Customer_ID
HAVING COUNT(*) >= 5 AND return_rate_pct > 40
ORDER BY return_rate_pct DESC;

-- Find the single most common reason for a return within each specific region.

SELECT Region, Return_Reason, reason_count
FROM (
    SELECT
        Region,
        Return_Reason,
        COUNT(*) AS reason_count,
        RANK() OVER (PARTITION BY Region ORDER BY COUNT(*) DESC) AS rnk
    FROM orders_returns
    WHERE Return_Status = 'Yes'
    GROUP BY Region, Return_Reason
) ranked
WHERE rnk = 1
ORDER BY reason_count DESC;

-- Prove whether logistical failures (late deliveries) lead to higher return rates.

SELECT
    CASE WHEN Was_Late = 1 THEN 'Late Delivery' ELSE 'On-Time Delivery' END AS Delivery_Status,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) AS total_returns,
    ROUND(100.0 * SUM(CASE WHEN Return_Status = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS return_rate_pct
FROM orders_returns
GROUP BY Was_Late;