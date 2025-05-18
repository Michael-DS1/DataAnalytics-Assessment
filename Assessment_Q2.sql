-- Analyze average transactions per customer per month and categorize frequency
WITH customer_tx_stats AS (
    SELECT
        s.owner_id,
        COUNT(*) AS total_transactions,
        -- Ensure we always have at least 1 month to avoid division by zero
        GREATEST(
            PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM MAX(s.transaction_date)),
                        EXTRACT(YEAR_MONTH FROM MIN(s.transaction_date))) + 1,
            1
        ) AS active_months
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
),
customer_tx_rates AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions * 1.0 / active_months, 2) AS avg_tx_per_month,
        CASE 
            WHEN total_transactions * 1.0 / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions * 1.0 / active_months >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_tx_stats
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM customer_tx_rates
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
