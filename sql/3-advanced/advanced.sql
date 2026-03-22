-- Answer all the questions below with advanced SQL queries (partitioning, CASE WHENs)
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. Where are located the clients that ordered more than the average?
WITH customer_order_counts AS (
    SELECT 
        c.customer_unique_id, 
        c.customer_state,
        c.customer_city,
        COUNT(o.order_id) AS total_orders
    FROM olist_customers_dataset c
    LEFT JOIN olist_orders_dataset o 
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id, c.customer_state, c.customer_city
),
average_order AS (
    SELECT AVG(total_orders) AS avg_order_count
    FROM customer_order_counts
)
SELECT 
    customer_unique_id,
    customer_city,
    customer_state,
    total_orders
FROM customer_order_counts
WHERE total_orders > (SELECT avg_order_count FROM average_order)
ORDER BY total_orders DESC;

-- 2. Segment clients in categories based on the amount spent (use CASE WHEN)
SELECT 
    c.customer_unique_id,
    SUM(op.payment_value) AS total_spent,
    CASE 
        WHEN SUM(op.payment_value) >= 1000 THEN 'Diamond'
        WHEN SUM(op.payment_value) >= 500 THEN 'Golden'
        WHEN SUM(op.payment_value) >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
FROM 
    olist_customers_dataset c
LEFT JOIN 
    olist_orders_dataset o ON c.customer_id = o.customer_id
LEFT JOIN 
    olist_order_payments_dataset op ON o.order_id = op.order_id
GROUP BY 
    c.customer_unique_id
ORDER BY
	total_spent DESC;

-- 3. Compute the difference in days between the first and last order of a client. Compute then the average (use PARTITION BY)
SELECT
    customer_id,
    first_order,
    last_order,
    DATEDIFF(last_order, first_order) AS days_difference,
    AVG(DATEDIFF(last_order, first_order)) OVER () AS avg_days_difference
FROM (
    SELECT
        customer_id,
        DATE(MIN(order_purchase_timestamp)) AS first_order,
        DATE(MAX(order_purchase_timestamp)) AS last_order
    FROM olist_orders_dataset
    GROUP BY customer_id
) AS customer_orders;

-- 4. Add a column to the query in basics question 2.: what was their first product category purchased?
WITH RankedPurchases AS (
    SELECT 
        c.customer_unique_id,
        c.customer_id,
        p.product_category_name,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp ASC, oi.order_item_id ASC
        ) AS purchase_rank
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
),
FirstCategory AS (
    SELECT 
        customer_unique_id, 
        product_category_name AS first_category
    FROM RankedPurchases
    WHERE purchase_rank = 1
),
CustomerSpending AS (
    SELECT 
        c.customer_unique_id,
        SUM(op.payment_value) AS total_spent
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset op ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT 
    s.customer_unique_id,
    s.total_spent,
    f.first_category,
    CASE 
        WHEN s.total_spent >= 1000 THEN 'Diamond'
        WHEN s.total_spent >= 500 THEN 'Golden'
        WHEN s.total_spent >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
FROM CustomerSpending s
LEFT JOIN FirstCategory f ON s.customer_unique_id = f.customer_unique_id;