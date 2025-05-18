-- Identify users who have at least one funded savings plan and one funded investment plan
SELECT 
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
    SUM(s.amount) AS total_deposits
FROM users_customuser u
JOIN plans_plan p ON u.id = p.owner_id
JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE p.is_deleted = 0 AND p.is_archived = 0 -- Exclude deleted/archived plans
GROUP BY u.id, u.name
HAVING COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) >= 1
   AND COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) >= 1
ORDER BY total_deposits DESC;
