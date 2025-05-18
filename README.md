# DataAnalytics-Assessment

## Question 1: High-Value Customers with Multiple Products

**Objective:**  
Identify users who have both a savings and an investment plan, and calculate the total deposits they have made.

**Approach:**  
1. Join `users_customuser`, `plans_plan`, and `savings_savingsaccount` to connect users with their plans and deposits.
2. Use `CASE` within aggregation to separately count savings and investment plans by `plan_type_id`.
3. Group by user and filter out those who have **at least one** of each plan type.
4. Calculate the sum of all deposits (from `savings_savingsaccount.amount`).
5. Filter out deleted/archived plans for accuracy.

**Assumptions:**
- `plan_type_id = 1` → savings plan
- `plan_type_id = 2` → investment plan
- Funded plans are defined as those with associated deposits in `savings_savingsaccount`.

**Challenges:**  
A key challenge was ensuring that plans are "funded." I addressed this by ensuring that each selected plan had at least one deposit record in `savings_savingsaccount`.


## Question 2: Transaction Frequency Analysis

**Objective:**  
Categorize users based on the frequency of their savings transactions per month.

**Approach:**
1. From `savings_savingsaccount`, count the total number of transactions per user.
2. Calculate the active number of months for each user using the first and last transaction dates (in `EXTRACT(YEAR_MONTH)` format).
3. Compute average transactions per month per user.
4. Use a `CASE` statement to bucket users into three categories:
   - High Frequency: ≥10 transactions/month
   - Medium Frequency: 3–9 transactions/month
   - Low Frequency: ≤2 transactions/month
5. Group by frequency category to get total users and average transaction frequency.

**Challenges:**
- I ensured that the active period is **at least one month** to prevent division by zero errors.
- I used `PERIOD_DIFF` for month difference calculation and `GREATEST(..., 1)` as a safeguard.


## Question 3: Account Inactivity Alert

**Objective:**  
Identify active savings or investment plans with no deposit transactions in the last 365 days.

**Approach:**
1. Use a CTE `last_tx` to find the most recent transaction date per plan from `savings_savingsaccount`.
2. Join this with `plans_plan` filtered to active plans (`is_deleted = 0` and `is_archived = 0`).
3. Select plans where:
   - There are no transactions at all, or
   - The last transaction was more than 365 days ago.
4. Calculate inactivity days as the difference between today and the last transaction date (or an old default date if no transaction).
5. Classify plan type based on `plan_type_id`.

**Challenges:**
- Handling plans with no transaction records required the use of `LEFT JOIN` and `COALESCE`.
- Ensured that `inactivity_days` is meaningful even when no transactions exist by using a default historic date.



## Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate customer lifetime value based on account tenure and transaction volume.

**Approach:**
1. Calculate account tenure in months from `date_joined` to current date (minimum 1 month).
2. Aggregate total transactions and average transaction amount per customer from `savings_savingsaccount`.


**Challenges:**
- Prevented division by zero for tenure less than one month.
- Accounted for customers with zero transactions by using `LEFT JOIN` and `COALESCE`.


