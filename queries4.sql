"Find the number of events per day per channel"
SELECT DATE_TRUNC('day',occurred_at) AS day,
   		channel, 
   		COUNT(*) as number_events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

"Find de average per day per event"
SELECT AVG(number_events),
		channel
FROM
			(SELECT DATE_TRUNC('day',occurred_at) AS day,
   			channel, 
   			COUNT(*) as number_events	
			FROM web_events
			GROUP BY 1,2) sub
GROUP BY 2
ORDER BY 1 DESC;



"The average amount of each type of paper sold on the first month that any order was placed in the orders table (in terms of quantity)."
SELECT AVG(standard_qty) AS avr_standard,
		AVG(gloss_qty) AS avr_gloss,
        AVG(poster_qty) AS avr_poster
FROM orders
WHERE DATE_TRUNC('month',occurred_at) = (SELECT MIN(DATE_TRUNC('month',occurred_at)) AS min_month
FROM orders)

"The total of usd of the orders made in the same month of the first purchase"
SELECT SUM(total_amt_usd) AS total
FROM orders
WHERE DATE_TRUNC('month',occurred_at) = (SELECT MIN(DATE_TRUNC('month',occurred_at)) AS min_month
FROM orders)



"A. Provide the name of the sales_rep in each region with the largest 
amount of total_amt_usd sales."
SELECT t3.Region, t3.Sales_rep, t3.Total_usd
FROM (	SELECT Region,
				MAX(Total_usd) AS Total_usd
		FROM (	SELECT s.name Sales_rep,
				r.name Region,
		        SUM(o.total_amt_usd) AS Total_usd
				FROM sales_reps s
				JOIN region r
				ON s.region_id = r.id
				JOIN accounts a
				ON a.sales_rep_id = s.id
				JOIN orders o
				ON o.account_id = a.id
				GROUP BY 1,2) t1
		GROUP BY Region) t2

JOIN (	SELECT s.name Sales_rep,
		r.name Region,
        SUM(o.total_amt_usd) AS Total_usd
		FROM sales_reps s
		JOIN region r
		ON s.region_id = r.id
		JOIN accounts a
		ON a.sales_rep_id = s.id
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY 1,2
		ORDER BY 3) t3
ON t3.Region=t2.Region AND t3.Total_usd = t2.Total_usd;

"B. For the region with the largest (sum) of sales total_amt_usd, 
how many total (count) orders were placed?"

"This is the long query"
SELECT COUNT(o.total) Number_orders,
		r.name Region_a     
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
WHERE r.name = (SELECT Region
				FROM (	SELECT r.name Region,
				        SUM(o.total_amt_usd) AS Total_usd
					    FROM orders o
					    JOIN accounts a
					    ON o.account_id = a.id
					    JOIN sales_reps s
					    ON a.sales_rep_id = s.id
					    JOIN region r
					    ON s.region_id = r.id
					    GROUP BY 1) t1
				WHERE total_usd = (	SELECT MAX(Total_usd) AS Total_usd
									FROM(SELECT r.name Region,
									        SUM(o.total_amt_usd) AS Total_usd
									    FROM orders o
									    JOIN accounts a
									    ON o.account_id = a.id
									    JOIN sales_reps s
									    ON a.sales_rep_id = s.id
									    JOIN region r
									    ON s.region_id = r.id
									    GROUP BY 1) t2)
				)
  GROUP BY 2;

"This is the short query"
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);


"C. How many accounts had more total purchases than the account name
 which has bought the most standard_qty paper throughout their 
 lifetime as a customer?"


"First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount:"

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
"Now, I want to use this to pull all the accounts with more total sales:"

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);
"This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery."

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;
"D.For the customer that spent the most (in total over their lifetime 
as a customer) total_amt_usd, how many web_events did they have for 
each channel?"


SELECT w.channel,
		a.name Account,
		COUNT (*) AS Number_events
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE  a.name = (	SELECT Account
					FROM (	SELECT a.name Account,
									SUM(o.total_amt_usd) Total_usd
                          	FROM orders o
                          	JOIN accounts a
                          	ON o.account_id=a.id
                          	GROUP BY 1
                          	ORDER BY 2 DESC
                          	LIMIT 1) AS t1)
GROUP BY 1,2
ORDER BY 3 DESC;

"second solution"
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

"E.What is the lifetime average amount spent in terms of 
total_amt_usd for the top 10 total spending accounts?"

"This provides the AVG for each of the 10 top accounts"
SELECT a.name Account,
		AVG(o.total_amt_usd) Avg_Total_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name IN (SELECT Account
                FROM (SELECT a.name Account,
		SUM(o.total_amt_usd) Total_usd
                      FROM accounts a
                      JOIN orders o
                      ON o.account_id = a.id
                      GROUP BY 1
                      ORDER BY 2 DESC
                      LIMIT 10) t1)
GROUP BY 1
ORDER BY 2 DESC;

"But the solution is "
SELECT AVG(Total_usd)
FROM (SELECT a.name Account,
		SUM(o.total_amt_usd) Total_usd
                      FROM accounts a
                      JOIN orders o
                      ON o.account_id = a.id
                      GROUP BY 1
                      ORDER BY 2 DESC
                      LIMIT 10) t1;


"F.What is the lifetime average amount spent in terms of total_amt_usd, 
including only the companies that spent more per order, on average, 
than the average of all orders."

SELECT AVG(o.total_amt_usd) Avg_Total_usd
FROM orders o;



SELECT a.name Account,
		AVG(o.total_amt_usd) Avg_order
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) Avg_Total_usd
								FROM orders o)
 
ORDER BY 2 DESC ;


"Final answer"
SELECT AVG(t1.Avg_order)
FROM (SELECT a.name Account,
		AVG(o.total_amt_usd) Avg_order
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) Avg_Total_usd
                                      FROM orders o)) t1;


"USING WITH TO CREATE CTE"
"A. Provide the name of the sales_rep in each region with the largest 
amount of total_amt_usd sales.

B. For the region with the largest (sum) of sales total_amt_usd, 
how many total (count) orders were placed?

C. How many accounts had more total purchases than the account name
 which has bought the most standard_qty paper throughout their 
 lifetime as a customer?

D.For the customer that spent the most (in total over their lifetime 
as a customer) total_amt_usd, how many web_events did they have for 
each channel?

E.What is the lifetime average amount spent in terms of 
total_amt_usd for the top 10 total spending accounts?

F.What is the lifetime average amount spent in terms of total_amt_usd, 
including only the companies that spent more per order, on average, 
than the average of all orders."

"A"

WITH total_rep AS (SELECT s.name Sales_rep,
				r.name Region,
		        SUM(o.total_amt_usd) AS Total_usd
				FROM sales_reps s
				JOIN region r
				ON s.region_id = r.id
				JOIN accounts a
				ON a.sales_rep_id = s.id
				JOIN orders o
				ON o.account_id = a.id
				GROUP BY 1,2)

SELECT t.Region, t.Sales_rep, t.Total_usd
FROM (	SELECT Region,
	    MAX(Total_usd) AS Total_usd
		FROM total_rep
		GROUP BY Region) t1
JOIN total_rep t
ON t.Region = t1.Region AND t.Total_usd = t1.Total_usd;

"Second option"

WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;


"B"

WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

"C"


WITH t1 AS (SELECT a.name Account,
					SUM(o.standard_qty) Standard_qty,
                       SUM(o.total) total
                FROM orders o
                JOIN accounts a
                ON a.id=o.account_id
                GROUP BY a.name
                ORDER BY 2 DESC
                LIMIT 1),
  t2 AS (SELECT a.name Accounts
          FROM orders o
          JOIN accounts a
          ON a.id=o.account_id
          GROUP BY 1
          HAVING SUM(o.total)> (SELECT total
                               	FROM t1))
         
          
SELECT COUNT(*)
FROM t2

"D"

WITH t1 AS (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1)
                           
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (SELECT id
                     			   FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

"E"

WITH t1 AS (SELECT a.name Account,
		SUM(o.total_amt_usd) Total_usd
                      FROM accounts a
                      JOIN orders o
                      ON o.account_id = a.id
                      GROUP BY 1
                      ORDER BY 2 DESC
                      LIMIT 10)
SELECT AVG(Total_usd)
FROM t1

"F"
WITH t1 AS (SELECT a.name Account,
		AVG(o.total_amt_usd) Avg_order
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) Avg_Total_usd
                                      FROM orders o))
                                     
SELECT AVG(t1.Avg_order)
FROM t1

"This is a longer solution"

WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;