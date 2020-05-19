"""
Aggregation Questions
Use the SQL environment below to find the solution for each of the following questions. If you get stuck or want to check your answers, you can find the answers at the top of the next concept.

Find the total amount of poster_qty paper ordered in the orders table.

Find the total amount of standard_qty paper ordered in the orders table.

Find the total dollar amount of sales using the total_amt_usd in the orders table.

Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. This should give a dollar amount for each order in the table.

Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
"""

SELECT SUM(poster_qty) AS Total_poster,
	   SUM(standard_qty) AS Total_standard,
       SUM(total_amt_usd) AS USD_total
FROM orders;

SELECT standard_amt_usd + gloss_amt_usd AS Total_USD
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

'''
When was the earliest order ever placed? You only need to return the date.

Try performing the same query as in question 1 without using an aggregation function.

When did the most recent (latest) web_event occur?

Try to perform the result of the previous query without using an aggregation function.

Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.

Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?
'''
SELECT MIN(occurred_at)
FROM orders;

SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

SELECT MAX(occurred_at)
FROM web_events;

SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

SELECT AVG(standard_amt_usd) AS usd_st,
		AVG(gloss_amt_usd) AS usd_gl,
        AVG(poster_amt_usd) AS usd_ps,
        AVG(standard_qty) AS qty_st,
        AVG(gloss_qty)AS qty_gl,
        AVG(poster_qty) AS qty_ps
FROM orders;

SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
"Since there are 6912 orders - we want the average of the 3457 and 3456 order amounts when ordered. This is the average of 2483.16 and 2482.55. This gives the median of 2482.855. This obviously isn't an ideal way to compute. If we obtain new orders, we would have to change the limit. SQL didn't even calculate the median for us. The above used a SUBQUERY, but you could use any method to find the two necessary values, and then you just need the average of them."


"""
Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.

Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.

Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.

Who was the primary contact associated with the earliest web_event?

What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.

Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.
"""

SELECT a.name account,
       o.occurred_at dates
FROM accounts a
JOIN orders o
ON o.account_id=a.id
ORDER BY dates
LIMIT 1;



SELECT SUM(o.total_amt_usd) Sales,
		a.name Account
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY Account
ORDER BY Sales;



SELECT w.channel Channel,
		w.occurred_at  Dates,
        a.name Account
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY Dates DESC
LIMIT 1;
		


SELECT channel Channel,
		COUNT(channel) Number_Times
FROM web_events
GROUP BY channel
ORDER BY Number_Times;




SELECT a.primary_poc Contact,
		w.occurred_at Dates
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
ORDER BY Dates
LIMIT 1;



SELECT a.name Account,
		MIN(o.total_amt_usd) Total_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY Account
ORDER BY Total_usd


SELECT COUNT(s.name) Number_rep,
		r.name Region
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
GROUP BY Region
ORDER BY Number_rep;

"""
For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.


For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.


Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.


Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.

"""

SELECT 	a.name Account,
		AVG(o.standard_qty) Standard_qty,
		AVG(o.gloss_qty) Gloss_qty,
        AVG(o.poster_qty) Poster_qty
       
FROM orders o
JOIN accounts a
ON o.account_id=a.id
GROUP BY Account
ORDER BY Account;


SELECT 	a.name Account,
		AVG(o.standard_amt_usd) Standard_qty,
		AVG(o.gloss_amt_usd) Gloss_qty,
        AVG(o.poster_amt_usd) Poster_qty
       
FROM orders o
JOIN accounts a
ON o.account_id=a.id
GROUP BY Account
ORDER BY Account;


SELECT 	COUNT(w.channel) Channel_Times,
		w.channel Channel,
        s.name Sales_rep
FROM web_events w
JOIN accounts a
ON w.account_id=a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY Sales_rep, Channel 
ORDER BY Channel_Times DESC;

SELECT 	COUNT(w.channel) Channel_Times,
		w.channel Channel,
        r.name Region
FROM web_events w
JOIN accounts a
ON w.account_id=a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id=r.id
GROUP BY Region, Channel
ORDER BY Channel_Times DESC;


"""
Use DISTINCT to test if there are any accounts associated with more than one region.
Have any sales reps worked on more than one account?
"""

SELECT 	a.name Account, r.name Region
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id=r.id

"351 rows then compare with DISTINCT"
SELECT DISTINCT a.name
FROM accounts a
"also 351"

SELECT s.name Sales_rep, a.name Account
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id=s.id


SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

"""
How many of the sales reps have more than 5 accounts that they manage?
How many accounts have more than 20 orders?
Which account has the most orders?
Which accounts spent more than 30,000 usd total across all orders?
Which accounts spent less than 1,000 usd total across all orders?
Which account has spent the most with us?
Which account has spent the least with us?
Which accounts used facebook as a channel to contact customers more than 6 times?
Which account used facebook most as a channel?
Which channel was most frequently used by most accounts?
"""

SELECT COUNT(a.name)	Number_Accounts,
		s.name Sales_Rep
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY Sales_Rep
HAVING COUNT(a.name) >5
ORDER BY Number_Accounts DESC
"Answer 34"

SELECT a.name Accounts,
		COUNT(o.total) Number_Orders
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
HAVING COUNT(o.total) > 20
ORDER BY NUmber_Orders DESC;
"Answer 120"

SELECT a.name Accounts,
		COUNT(o.total) Number_Orders
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
ORDER BY NUmber_Orders DESC;
"Leucadia National = 71"

SELECT a.name Accounts,
		SUM(o.total_amt_usd) Total_USD
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
HAVING SUM(o.total_amt_usd)>30000
ORDER BY Total_USD DESC;
"Answer 204 accounts starting at EOG Resources and ending at American Airlines Group"

SELECT a.name Accounts,
		SUM(o.total_amt_usd) Total_USD
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
HAVING SUM(o.total_amt_usd)< 1000
ORDER BY Total_USD DESC;

"Level 3 Communications	881.73
Delta Air Lines	859.64
Nike	390.25"

SELECT a.name Accounts,
		SUM(o.total_amt_usd) Total_USD
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
ORDER BY Total_USD DESC
LIMIT 1;
"EOG Resources	382873.30"

SELECT a.name Accounts,
		SUM(o.total_amt_usd) Total_USD
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY Accounts
ORDER BY Total_USD
LIMIT 1;
"Nike 390.25"




SELECT a.name Accounts,
		w.channel Channel,
		COUNT(w.channel) Number_Times_Channel
FROM accounts a
JOIN web_events w
ON w.account_id=a.id
WHERE w.channel LIKE 'facebook'
GROUP BY Accounts, Channel
HAVING COUNT(w.channel) > 6
ORDER BY Number_Times_Channel DESC;

"46 Gilead Sciences - Laboratory Corp America"

"Similar answer using the below code"
SELECT a.name Accounts,
		w.channel Channel,
		COUNT(w.channel) Number_Times_Channel
FROM accounts a
JOIN web_events w
ON w.account_id=a.id
GROUP BY Accounts, Channel
HAVING w.channel LIKE 'facebook'AND COUNT(w.channel) > 6
ORDER BY Number_Times_Channel DESC;





SELECT a.name Accounts,
		w.channel Channel,
		COUNT(w.channel) Number_Times_Channel
FROM accounts a
JOIN web_events w
ON w.account_id=a.id
WHERE w.channel LIKE 'facebook'
GROUP BY Accounts, Channel
ORDER BY Number_Times_Channel DESC;

"Gilead Sciences 16"



SELECT w.channel Channel,
		COUNT(w.channel) Number_Times_Channel
FROM web_events w
GROUP BY Channel
ORDER BY Number_Times_Channel DESC;
"Direct 5298"
"Different approach to the same question"
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;

"""
Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?
In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
"""

SELECT SUM(o.total_amt_usd) Total_USD,
		DATE_PART('year',o.occurred_at)  ord_year
FROM orders o
GROUP BY 2
ORDER BY 1 DESC;
"
12864917.92	2016
5752004.94	2015
4069106.54	2014
377331.00	2013
78151.43	2017
"
"When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller totals than all other years. If we look further at the monthly data, we see that for 2013 and 2017 there is only one month of sales for each of these years (12 for 2013 and 1 for 2017). Therefore, neither of these are evenly represented. Sales have been increasing year over year, with 2016 being the largest sales to date. At this rate, we might expect 2017 to have the largest sales."


SELECT SUM(o.total_amt_usd) Total_USD,
		DATE_PART('month',o.occurred_at)  ord_month
FROM orders o
GROUP BY 2
ORDER BY 1 DESC;
"
3129411.98	12
2427505.97	10
2390033.75	11
2017216.88	9
1978731.15	7
1918107.22	8
1871118.52	6
1659987.88	3
1562037.74	4
1537082.23	5
1337661.87	1
1312616.64	2
"
"The solution proposed is"

"In order for this to be 'fair', we should remove the sales from 2013 and 2017. For the same reasons as discussed above."

SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 
"The greatest sales amounts occur in December (12)."

"I used the below code to see if the data was evenly distrubuted"
SELECT DATE_PART('month',o.occurred_at)  Month_,
		COUNT(o.total) Number_Orders
FROM orders o
GROUP BY 1
ORDER BY 1 DESC;

12	882
11	713
10	675
9	602
8	603
7	571
6	527
5	518
4	472
3	482
2	409
1	458


SELECT COUNT(o.total) Number_Orders,
		DATE_PART('year',o.occurred_at) Year_ord
FROM orders o
GROUP BY 2
ORDER BY 1 DESC;

"Again, 2016 by far has the most amount of orders, but again 2013 and 2017 are not evenly represented to the other years in the dataset."

SELECT COUNT(o.total) Number_Orders,
		DATE_PART('month',o.occurred_at) Year_ord
FROM orders o
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 2
ORDER BY 1 DESC;
"December still has the most sales, but interestingly, November has the second most sales (but not the most dollar sales. To make a fair comparison from one month to another 2017 and 2013 data were removed"

"I used the below code to see if the year was evenly distrubuted"
SELECT DATE_PART('year',o.occurred_at) Year_,
		COUNT(o.total) Number_Orders
FROM orders o
GROUP BY 1
ORDER BY 2 DESC;
2016	3757
2015	1725
2014	1306
2013	99
2017	25

SELECT DATE_PART('year', o.occurred_at) Year_,
		DATE_PART('month', o.occurred_at) Month_,
        a.name Account,
        SUM(o.gloss_amt_usd) Gloss_USD
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name LIKE 'Walmart'
GROUP BY 1,2,3
ORDER BY 4 DESC;

2016	5	Walmart	9257.64


"""
Write a query to display for each order, the account ID, total amount of the 
order, and the level of the order - ‘Large’ or ’Small’ - depending on 
if the order is $3000 or more, or smaller than $3000.

Write a query to display the number of orders in each of three categories, 
based on the total number of items in each order. The three categories are: 
'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

We would like to understand 3 different levels of customers based on 
the amount associated with their purchases. The top level includes 
anyone with a Lifetime Value (total sales of all orders) greater than 
200,000 usd. 
The second level is between 200,000 and 100,000 usd. The lowest level 
is anyone under 100,000 usd. Provide a table that includes the level 
associated with each account. 
You should provide the account name, the total sales of all orders for 
the customer, and the level. 
Order with the top spending customers listed first.


We would now like to perform a similar calculation to the first, 
but we want to obtain the total amount spent by customers 
only in 2016 and 2017. Keep the same levels as in the previous question. 
Order with the top spending customers listed first.


We would like to identify top performing sales reps, which are sales 
reps associated with more than 200 orders. 
Create a table with the sales rep name, the total number of orders, 
and a column with top or not depending on if they have more than 200 orders. 
Place the top sales people first in your final table.


The previous didn't account for the middle, nor the dollar amount 
associated with the sales. 
Management decides they want to see these characteristics represented as well.
We would like to identify top performing sales reps, which are sales 
reps associated with more than 200 orders or more than 750000 in total sales. 
The middle group has any rep with more than 150 orders or 500000 in sales. 
Create a table with the sales rep name, the total number of orders, total 
sales across all orders, and a column with top, middle, or low depending 
on this criteria. Place the top sales people based on dollar amount of 
sales first in your final table. You might see a few upset sales people
by this criteria!
"""

SELECT a.id, o.total_amt_usd, 
		CASE WHEN o.total_amt_usd>=3000 THEN 'Large' 			
		ELSE 'Small' END AS level_or_order
FROM accounts a
JOIN orders o
ON o.account_id = a.id



SELECT CASE WHEN o.total >= 2000 THEN 'At least 2000'
			WHEN o.total >= 1000 AND o.total < 2000 THEN 'Between 1000 and 2000'
            WHEN o.total <1000 THEN 'Less than 1000' END AS Categories,
		COUNT(*) Number_orders
FROM orders o
GROUP BY 1;

"Between 1000 and 2000	511
Less than 1000	6331
At least 2000	70"

SELECT CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top Level'
			WHEN SUM(o.total_amt_usd) >=100000 AND SUM(o.total_amt_usd) <=200000 THEN 'Medium Level'
            WHEN SUM(o.total_amt_usd) <100000 THEN 'Lowest Level' END AS Lifetime_value,
            a.name Account,
            SUM(o.total_amt_usd) Total_USD
FROM orders o
JOIN accounts a
ON o.account_id=a.id
GROUP BY 2
ORDER BY 3 DESC;




SELECT	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top Level'
			WHEN SUM(o.total_amt_usd) >=100000 AND SUM(o.total_amt_usd) <=200000 THEN 'Medium Level'
            WHEN SUM(o.total_amt_usd) <100000 THEN 'Lowest Level' END AS Lifetime_value,
		SUM(o.total_amt_usd) Total_USD,
		a.name
FROM accounts a
JOIN orders o
ON o.account_id=a.id
WHERE o.occurred_at >'2015-12-31'
GROUP BY 3
ORDER BY 2 DESC
'322'
Pacific Life	255319.18	top
Nike	390.25	low



SELECT s.name, 
		COUNT(o.total) Total_orders,
        CASE WHEN COUNT(o.total) >200 THEN 'Top' ELSE 'Not' END AS Performance
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;
Earlie Schleusner	335	Top
"50"

SELECT s.name, 
		COUNT(o.total) Total_orders,
		SUM(o.total_amt_usd) Total_sales,
        CASE WHEN COUNT(o.total) >200 OR SUM(o.total_amt_usd)>750000 THEN 'Top' 
        WHEN (COUNT(o.total) >150 AND COUNT(o.total)<=200) OR (SUM(o.total_amt_usd)>500000 AND SUM(o.total_amt_usd)<=750000)  THEN  'middle' ELSE 'low' END AS Performance
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;
Earlie Schleusner	335	1098137.72	Top
Nakesha Renn	13	49361.11	low