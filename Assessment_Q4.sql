WITH customer_stats AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE), 1) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        COALESCE(AVG(s.amount), 0) AS avg_transaction_amount
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, u.first_name, u.last_name, u.date_joined
)

SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(
        (total_transactions * 1.0 / tenure_months) * 12 * (avg_transaction_amount * 0.001),
        2
    ) AS estimated_clv
FROM customer_stats
ORDER BY estimated_clv DESC;
