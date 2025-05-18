-- Find active plans with no deposit transactions in the last 365 days
WITH last_tx AS (
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY plan_id
)

SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.plan_type_id = 1 THEN 'Savings'
        WHEN p.plan_type_id = 2 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    COALESCE(l.last_transaction_date, DATE('1970-01-01')) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, COALESCE(l.last_transaction_date, DATE('1970-01-01'))) AS inactivity_days
FROM plans_plan p
LEFT JOIN last_tx l ON p.id = l.plan_id
WHERE p.is_deleted = 0
  AND p.is_archived = 0
  AND (
       l.last_transaction_date IS NULL -- no transaction at all
       OR l.last_transaction_date < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY) -- no tx in last year
      )
ORDER BY inactivity_days DESC;
