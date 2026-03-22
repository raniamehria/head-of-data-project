-- Answer all the questions below with basics SQL queries
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. What are the possible values of an order status? 
SELECT DISTINCT order_status
FROM olist_orders_dataset

-- 2. Who are the 5 last customers that purchased a DELIVERED order (order with status DELIVERED)?
-- print their customer_id, their unique_id, and city
SELECT
	c.customer_id,
	c.customer_unique_id,
	c.customer_city
FROM olist_customers_dataset AS c
LEFT JOIN olist_orders_dataset AS o
	ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
ORDER BY o.order_purchase_timestamp DESC
LIMIT 5

-- 3. Add a column is_sp which returns 1 if the customer is from São Paulo and 0 otherwise
SELECT 
	c.customer_id,
	c.customer_unique_id,
	c.customer_city,
	CASE WHEN c.customer_city LIKE '%sao paoblo%' 
	THEN 1 
	ELSE 0
	END AS is_sp
FROM olist_customers_dataset AS c


-- 4. add a new column: what's the product category associated to the order?
SELECT 
	c.customer_id,
	c.customer_unique_id,
	c.customer_city,
	CASE WHEN c.customer_city LIKE '%sao paoblo%' 
	THEN 1 
	ELSE 0
	END AS is_sp
FROM olist_customers_dataset AS c
LEFT JOIN olist_orders_dataset AS o ON c.customer_id = o.customer_id
LEFT JOIN olist_order_items_dataset AS oi ON oi.order_id=o.order_id
LEFT JOIN olist_products_dataset AS p ON oi.product_id = p.product_id
