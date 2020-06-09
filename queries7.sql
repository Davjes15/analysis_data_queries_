"Each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)"
SELECT *
FROM accounts a
FULL JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL

"write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the 
< comparison operator on accounts.primary_poc and sales_reps.name, like so: accounts.primary_poc < sales_reps.name"
SELECT a.name Account_name, a.primary_poc Contact, s.name Sales_name
FROM accounts a
LEFT JOIN sales_reps s
ON a.sales_rep_id = s.id AND a.primary_poc < s.name;

"Check two events occurred, one after another."
SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
       w1.channel AS w2_channel
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w2.occurred_at > w1.occurred_at
  AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w1.occurred_at

"UNION vs UNION ALL"
SELECT *
FROM accounts a1
WHERE a1.name = 'Walmart'

UNION ALL 

SELECT *
FROM accounts a2
WHERE a2.name = 'Disney';

"The same result can be obtained by"
SELECT *
FROM accounts
WHERE name='Walmart' OR name='Disney';

"Count number of times each name repeats in table double_accounts"
WITH double_accounts AS (
    SELECT *
      FROM accounts

    UNION ALL

    SELECT *
      FROM accounts
)

SELECT name,
       COUNT(*) AS name_count
 FROM double_accounts 
GROUP BY 1
ORDER BY 2 DESC