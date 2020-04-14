-- Lesson 4: Subqueries - Queries from Subquery Mania quiz

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