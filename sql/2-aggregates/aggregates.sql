-- Answer all the questions below with aggegate SQL queries
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. What was the total revenue and order count for 2018?
SELECT
    COUNT(DISTINCT oi.order_id) AS order_count_2018,
    SUM(COALESCE(oi.price, 0) + COALESCE(oi.freight_value, 0)) AS total_revenue_2018
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_orders_dataset AS o
    ON oi.order_id = o.order_id
WHERE strftime('%Y', o.order_purchase_timestamp) = '2018'
AND o.order_status = 'delivered'

-- 2. What is the total_sales, average_order_sales, and first_order_date by customer? 
-- Round the values to 2 decimal places & order by total_sales descending
-- limit to 1000 results
SELECT
    o.customer_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_sales,
    MIN(o.order_purchase_timestamp) AS first_order_date
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1000;

-- 3. Who are the top 10 most successful sellers?
SELECT 
    s.seller_id,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
JOIN olist_sellers_dataset s 
    ON oi.seller_id = s.seller_id
GROUP BY 1
ORDER BY total_sales DESC
LIMIT 10;

-- 4. What’s the preferred payment method by product category?
SELECT
    p.product_category_name,
    op.payment_type,
    COUNT(*) AS payment_count
FROM olist_products_dataset p
LEFT JOIN olist_order_items_dataset oi
    ON p.product_id = oi.product_id
LEFT JOIN olist_order_payments_dataset op
    ON oi.order_id = op.order_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name, op.payment_type
ORDER BY 1, 3 DESC;                     

