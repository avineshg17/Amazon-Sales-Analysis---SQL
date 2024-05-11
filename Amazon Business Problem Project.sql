-- 1. Find out the top 5 customers who made the highest profits. --

SELECT o.customer_id, c.customer_name, (p.price-p.cogs) as profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY 1,2,3
ORDER BY 3 DESC
LIMIT 5

-- 2. Find out the average quantity ordered per category. --

SELECT category, ROUND(AVG(quantity),2) as avg_qty
FROM orders 
WHERE category IS NOT NULL
GROUP BY 1

-- 3. Identify the top 5 products that have generated the highest revenue. --

SELECT p.product_id, p.product_name, ROUND(SUM(sale)::numeric,2) as total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5

-- 4. Determine the top 5 products whose revenue has decreased compared to the previous year.--

WITH last_yr_rev AS (
SELECT product_id, ROUND(SUM(sale)::numeric,2) as total_sales
FROM orders 
WHERE order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 1 ),

curr_yr_rev AS(
SELECT product_id, ROUND(SUM(sale)::numeric,2) as total_sales
FROM orders 
WHERE EXTRACT(YEAR FROM order_date) = 2023
GROUP BY 1)

SELECT lr.product_id, lr.total_sales as lst_yr_sale, cr.total_sales as curr_yr_sale,
       ROUND((lr.total_sales-cr.total_sales)/lr.total_sales*100::numeric,2) as decresing_ratio
FROM last_yr_rev lr
JOIN curr_yr_rev cr ON lr.product_id = cr.product_id
WHERE cr.total_sales < lr.total_sales
ORDER BY decresing_ratio DESC
LIMIT 5 

-- 5. Identify the highest profitable sub-category. --

SELECT sub_category, ROUND(SUM(sale)::numeric,2) as total_sales
FROM orders 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- 6. Find out the states with the highest total orders.--

SELECT state, COUNT(order_id) as total_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 7. Determine the month with the highest number of orders. --

SELECT EXTRACT(MONTH FROM order_date) as Month, COUNT(order_id) as total_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- 8. Calculate the profit margin percentage for each sale (Profit divided by Sales).--

WITH CTE AS (
SELECT order_id, (SUM(o.price_per_unit - p.cogs)) as profit, SUM(sale) as sale
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY 1)
	
SELECT *, profit/sale * 100 as profit_percentage FROM CTE	
GROUP BY order_id,profit,sale
	
				  
-- 9. Calculate the percentage contribution of each sub-category --

SELECT 
    sub_category,
    ROUND(SUM(sale)::numeric,2) AS total_amount,
    (SUM(sale) / (SELECT ROUND(SUM(sale)::numeric,2) FROM orders)) * 100 AS percentage_contribution
FROM 
    orders
WHERE sub_category IS  NOT NULL	
GROUP BY 1


-- 10.Identify top 2 category that has received maximum returns and their return % --
SELECT * FROM orders
SELECT * FROM returns

WITH CTE AS (
SELECT o.category, COUNT(r.return_id) as total_return
FROM orders o
JOIN returns r 
ON o.order_id = r.order_id
GROUP BY 1
ORDER BY total_return DESC
LIMIT 2 )

SELECT *,  total_return/SUM(total_return)*100 as return_percent 
FROM CTE
GROUP BY category,total_return






