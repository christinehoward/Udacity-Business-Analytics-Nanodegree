-- SUBQUERIES Practice

-- We want to find the average number of events for each day for each channel. The first table will provide us the number of events for each day and channel, and then we will need to average these values together using a second query.
SELECT
  channel,
  AVG(web_events_total) average_events
FROM (SELECT
  channel,
  DATE_TRUNC('day', occurred_at) AS day,
  COUNT(id) web_events_total
FROM web_events
GROUP BY 1,
         2) Subquery
GROUP BY 1
ORDER BY 2 DESC;

-- First, we needed to group by the day and channel. Then ordering by the number of events (the third column) gave us a quick way to answer the first question.
-- Finally, here we are able to get a table that shows the average number of events a day for each channel.


--Use DATE_TRUNC to pull month level information about the first order ever placed in the orders table
SELECT MIN(DATE_TRUNC('month', occurred_at))
FROM orders;

-- Use result of previous quer                             mkii9y to find only the orders that took place in the same month and year as the first order, and then pull the average for each type of paper qty in this month.
SELECT
  SUM(total_amt_usd) total_usd,
  AVG(total) avg_total_qty,
  AVG(standard_qty) avg_std_qty,
  AVG(poster_qty) avg_post_qty,
  AVG(gloss_qty) avg_gloss_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (SELECT
  MIN(DATE_TRUNC('month', occurred_at))
FROM orders) ;
-- An additional quiz question also asked for the sum total USD spent in the month of the first ever order placed, which is why I included the SUM of total_amt_usd.


-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- First, I found the total_amt_usd totals for each sales rep, and I also wanted the region where they work.
SELECT
  s.name repname,
  r.name region,
  SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1,
         2
ORDER BY 3 DESC;

-- Next, I found the max sales for each region.
SELECT
  region,
  MAX(total_sales) max_sales
FROM (SELECT
  s.name repname,
  r.name region,
  SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC) t1
GROUP BY 1;

-- For the final result, we need to join these 2 tables we have created.
-- T1 (or table 1) is nestled within T2 (table 2). We then need to join t2 and t3.
-- The purpose of creating t3 is to match the total_sales/region in t3 with the max_sales/region in t2.

SELECT
  T3.repname,
  T3.region,
  t3.total_sales
FROM (SELECT
  region,
  MAX(total_sales) max_sales
FROM (SELECT
  s.name repname,
  r.name region,
  SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1,2) t1
GROUP BY 1) t2
JOIN (SELECT
  s.name repname,
  r.name region,
  SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1,2
ORDER BY 3 DESC) t3
  ON t3.region = t2.region
  AND t3.total_sales = t2.max_sales;

-- In T2, we get the max sales for each region, and in t3, we get the top sales people, along with their sales totals and region.
-- We then need to match up these 2 tables, in order to ensure that we are only getting the top salesperson per region.
-- If we were to skip this part, or just limit to the number of regions, we would likely end up with more than 1 salesperson per region.
-- If you have a look at t2, you can see that when ordering descending and limiting by 4, you would get 2 salespeople from the same region (southeast).


-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

SELECT r.name, COUNT(o.total) total_orders
FROM orders o 
JOIN accounts a 
ON o.account_id = a.id 
JOIN sales_reps s 
ON a.sales_rep_id = s.id 
JOIN region r 
ON s.region_id = r.id 
GROUP BY 1

HAVING SUM(o.total_amt_usd) =
(SELECT MAX(total_amt)
FROM
(SELECT r.name region, SUM(o.total_amt_usd) total_amt
FROM orders o 
JOIN accounts a 
ON o.account_id = a.id 
JOIN sales_reps s 
ON a.sales_rep_id = s.id 
JOIN region r 
ON s.region_id = r.id 
GROUP BY 1 ) t1) ;

-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

SELECT
  r.name,
  COUNT(o.total) total_orders
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1
-- We first need to find the region with the largest (sum) of sales total_amt_usd
HAVING SUM(o.total_amt_usd) = (SELECT
  MAX(sales_total)
FROM (SELECT
  r.name region,
  SUM(o.total_amt_usd) sales_total
FROM region r
JOIN sales_reps s
  ON r.id = s.region_id
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1) col1);


-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

SELECT AVG(total_spent)
FROM
  (SELECT o.account_id, SUM(o.total_amt_usd) total_spent
  FROM orders o 
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10);


-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

WITH table1
AS (SELECT
  a.id,
  SUM(o.standard_qty) stn_count,
  SUM(o.total) total_orders
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1),

table2
AS (SELECT
  a.id
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1

HAVING SUM(o.total) > (SELECT
  total_orders
FROM table1))
SELECT
  COUNT(*)
FROM table2;


-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

WITH t1
AS (SELECT
  a.id,
  a.name,
  SUM(o.total_amt_usd) total_amt
FROM accounts a
JOIN orders o
  ON a.id = o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10)
-- First, we want to know the total_amt_usd for each of the top 10 total spending accounts. 
-- We first find the total_amt_usd for all accounts, by grouping by account, and then order by descending to see the highest total_amt_usd at the top.
-- We then limit this by 10 to find the top 10 accounts, and the first table here shows only these 10 accounts with their id, name, and sum of their lifetime total_amt_usd.

SELECT
  AVG(total_amt)
FROM t1;
-- We then find the average of the lifetime total_amt_usd for all 10 accounts in the first table ($304,846.969).