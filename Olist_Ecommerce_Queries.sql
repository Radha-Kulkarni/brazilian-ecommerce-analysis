-- ============================================================
--   OLIST BRAZILIAN E-COMMERCE — FULL SQL ANALYSIS
--   Database: olist_ecommerce
-- ============================================================

-- ============================================================
--   SECTION 1: DATABASE & TABLE SETUP
-- ============================================================

CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

-- 1. Customers
CREATE TABLE customers (
    customer_id            VARCHAR(50) PRIMARY KEY,
    customer_unique_id     VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city          VARCHAR(100),
    customer_state         VARCHAR(10)
);

-- 2. Orders
CREATE TABLE orders (
    order_id                       VARCHAR(50) PRIMARY KEY,
    customer_id                    VARCHAR(50),
    order_status                   VARCHAR(30),
    order_purchase_timestamp       DATETIME,
    order_approved_at              DATETIME,
    order_delivered_carrier_date   DATETIME,
    order_delivered_customer_date  DATETIME,
    order_estimated_delivery_date  DATETIME
);

-- 3. Order Items
CREATE TABLE order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2)
);

-- 4. Order Payments
CREATE TABLE order_payments (
    order_id              VARCHAR(50),
    payment_sequential    INT,
    payment_type          VARCHAR(30),
    payment_installments  INT,
    payment_value         DECIMAL(10,2)
);

-- 5. Products
CREATE TABLE products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name       VARCHAR(100),
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            INT,
    product_length_cm           INT,
    product_height_cm           INT,
    product_width_cm            INT
);

-- 6. Category Translation
CREATE TABLE category_translation (
    product_category_name         VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


-- ============================================================
--   SECTION 2: DATA LOADING
-- ============================================================

SET GLOBAL local_infile = 1;

-- Clear existing data before reload
TRUNCATE TABLE customers;
TRUNCATE TABLE orders;
TRUNCATE TABLE order_items;
TRUNCATE TABLE order_payments;
TRUNCATE TABLE products;
TRUNCATE TABLE category_translation;

-- Load all tables from CSV files
LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/yoges/OneDrive/Documents/Brazillian_Ecommerce/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify row counts
SELECT 'customers'          AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',                           COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',                      COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments',                   COUNT(*) FROM order_payments
UNION ALL
SELECT 'products',                         COUNT(*) FROM products
UNION ALL
SELECT 'category_translation',             COUNT(*) FROM category_translation;


-- ============================================================
--   SECTION 3: DATA QUALITY CHECKS
-- ============================================================

-- 3.1 NULL check on key order dates
SELECT 
    COUNT(*)                                                                    AS total_orders,
    SUM(CASE WHEN order_approved_at              IS NULL THEN 1 ELSE 0 END)    AS null_approved,
    SUM(CASE WHEN order_delivered_carrier_date   IS NULL THEN 1 ELSE 0 END)    AS null_carrier,
    SUM(CASE WHEN order_delivered_customer_date  IS NULL THEN 1 ELSE 0 END)    AS null_delivered
FROM orders;

-- 3.2 Order status distribution
SELECT order_status, COUNT(*) AS count
FROM orders
GROUP BY order_status
ORDER BY count DESC;

-- 3.3 NULL and zero-weight check in products
SELECT 
    COUNT(*)                                                                        AS total_products,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)                 AS null_category,
    SUM(CASE WHEN product_weight_g = 0  THEN 1 ELSE 0 END)                         AS zero_weight
FROM products;

-- 3.4 Payment type distribution
SELECT payment_type, COUNT(*) AS count
FROM order_payments
GROUP BY payment_type
ORDER BY count DESC;


-- ============================================================
--   SECTION 4: DATA CLEANING
-- ============================================================

-- 4.1 Create clean orders view (delivered orders only)
CREATE VIEW clean_orders AS
SELECT * FROM orders
WHERE order_status = 'delivered';

SELECT COUNT(*) AS delivered_orders FROM clean_orders;

-- 4.2 Inspect zero-weight products
SELECT product_id, product_category_name, product_weight_g
FROM products
WHERE product_weight_g = 0;

-- 4.3 Check for multi-row payments (installments)
SELECT order_id, COUNT(*) AS payment_rows
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
LIMIT 10;

-- 4.4 Verify join integrity
SELECT COUNT(DISTINCT o.order_id) AS orders_with_items
FROM clean_orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id;

SELECT COUNT(DISTINCT o.order_id) AS orders_with_payments
FROM clean_orders o
INNER JOIN order_payments op ON o.order_id = op.order_id;


-- ============================================================
--   SECTION 5: EXPLORATORY DATA ANALYSIS
-- ============================================================

-- Query 1: Overall key metrics
SELECT 
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS total_customers,
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    ROUND(AVG(oi.price), 2)                             AS avg_item_price,
    ROUND(SUM(oi.freight_value), 2)                     AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_gmv
FROM clean_orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- Query 2: Revenue by product category (top 10)
SELECT 
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    ROUND(SUM(oi.price), 2)         AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_price
FROM clean_orders o
JOIN order_items oi          ON o.order_id    = oi.order_id
JOIN products p              ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 3: Monthly revenue trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    ROUND(SUM(oi.price), 2)                          AS monthly_revenue
FROM clean_orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Query 4: Revenue by customer state (top 10)
SELECT 
    c.customer_state                AS state,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    ROUND(SUM(oi.price), 2)         AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_order_value
FROM clean_orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN customers c   ON o.customer_id  = c.customer_id
GROUP BY state
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 5: Payment method breakdown
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id)             AS total_orders,
    ROUND(SUM(op.payment_value), 2)         AS total_value,
    ROUND(AVG(op.payment_installments), 1)  AS avg_installments
FROM order_payments op
JOIN clean_orders o ON op.order_id = o.order_id
GROUP BY op.payment_type
ORDER BY total_orders DESC;


-- ============================================================
--   SECTION 6: ADVANCED ANALYSIS — WINDOW FUNCTIONS
-- ============================================================

-- Query 6: Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price), 2)                          AS revenue
    FROM clean_orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                                              AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100, 1
    )                                                                               AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- Query 7: Top 10 customers by lifetime value
WITH customer_spend AS (
    SELECT 
        o.customer_id,
        c.customer_city,
        c.customer_state,
        COUNT(DISTINCT o.order_id)  AS total_orders,
        ROUND(SUM(oi.price), 2)     AS lifetime_value
    FROM clean_orders o
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN customers c   ON o.customer_id  = c.customer_id
    GROUP BY o.customer_id, c.customer_city, c.customer_state
)
SELECT 
    customer_id,
    customer_city,
    customer_state,
    total_orders,
    lifetime_value,
    RANK() OVER (ORDER BY lifetime_value DESC) AS value_rank
FROM customer_spend
LIMIT 10;

-- Query 8: Category revenue rank with running total
WITH category_revenue AS (
    SELECT 
        COALESCE(ct.product_category_name_english, p.product_category_name) AS category,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
    GROUP BY category
)
SELECT 
    category,
    revenue,
    RANK() OVER (ORDER BY revenue DESC)                                                             AS revenue_rank,
    ROUND(SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2)                                                 AS revenue_pct
FROM category_revenue
ORDER BY revenue_rank
LIMIT 15;

-- Query 9: Freight as % of order value by state (top 10 highest)
SELECT 
    c.customer_state                                        AS state,
    ROUND(SUM(oi.price), 2)                                AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                        AS total_freight,
    ROUND(SUM(oi.freight_value) / SUM(oi.price) * 100, 1) AS freight_pct
FROM clean_orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN customers c   ON o.customer_id  = c.customer_id
GROUP BY state
ORDER BY freight_pct DESC
LIMIT 10;

-- Query 10: Seasonal analysis — revenue by calendar month
WITH monthly AS (
    SELECT 
        MONTH(o.order_purchase_timestamp)     AS month_num,
        MONTHNAME(o.order_purchase_timestamp) AS month_name,
        COUNT(DISTINCT o.order_id)            AS total_orders,
        ROUND(SUM(oi.price), 2)               AS revenue
    FROM clean_orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY month_num, month_name
)
SELECT 
    month_name,
    total_orders,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM monthly
ORDER BY month_num;


-- ============================================================
--   SECTION 7: FINAL SUMMARY VIEW
-- ============================================================

CREATE VIEW olist_final_summary AS
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')                AS month,
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category,
    c.customer_state                                                AS state,
    op.payment_type,
    COUNT(DISTINCT o.order_id)                                      AS total_orders,
    ROUND(SUM(oi.price), 2)                                         AS revenue,
    ROUND(SUM(oi.freight_value), 2)                                 AS freight,
    ROUND(AVG(oi.price), 2)                                         AS avg_price,
    ROUND(SUM(op.payment_value), 2)                                 AS payment_value
FROM clean_orders o
JOIN order_items oi          ON o.order_id    = oi.order_id
JOIN products p              ON oi.product_id = p.product_id
JOIN customers c             ON o.customer_id = c.customer_id
JOIN order_payments op       ON o.order_id    = op.order_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY month, category, state, payment_type;

-- Verify the view
SELECT COUNT(*)              AS total_rows    FROM olist_final_summary;
SELECT *                                      FROM olist_final_summary LIMIT 5;


-- ============================================================
--   SECTION 8: EXPORT RESULTS TO CSV
-- ============================================================

-- Export 1: Key metrics
SELECT 
    COUNT(DISTINCT o.order_id)                      AS total_orders,
    COUNT(DISTINCT o.customer_id)                   AS total_customers,
    ROUND(SUM(oi.price), 2)                         AS total_revenue,
    ROUND(AVG(oi.price), 2)                         AS avg_item_price,
    ROUND(SUM(oi.freight_value), 2)                 AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2)      AS total_gmv
FROM clean_orders o
JOIN order_items oi ON o.order_id = oi.order_id
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/key_metrics_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Export 2: Monthly revenue trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    ROUND(SUM(oi.price), 2)                          AS monthly_revenue
FROM clean_orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/monthly_revenue_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Export 3: Revenue by category
SELECT 
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT o.order_id)      AS total_orders,
    ROUND(SUM(oi.price), 2)         AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_price
FROM clean_orders o
JOIN order_items oi          ON o.order_id    = oi.order_id
JOIN products p              ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/category_revenue_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Export 4: Revenue by state
SELECT 
    c.customer_state                                        AS state,
    COUNT(DISTINCT o.order_id)                             AS total_orders,
    ROUND(SUM(oi.price), 2)                                AS total_revenue,
    ROUND(AVG(oi.price), 2)                                AS avg_order_value,
    ROUND(SUM(oi.freight_value) / SUM(oi.price) * 100, 1) AS freight_pct
FROM clean_orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN customers c   ON o.customer_id  = c.customer_id
GROUP BY state
ORDER BY total_revenue DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/state_revenue_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Export 5: Payment breakdown
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id)             AS total_orders,
    ROUND(SUM(op.payment_value), 2)         AS total_value,
    ROUND(AVG(op.payment_installments), 1)  AS avg_installments
FROM order_payments op
JOIN clean_orders o ON op.order_id = o.order_id
GROUP BY op.payment_type
ORDER BY total_orders DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payment_breakdown_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Export 6: Full summary view
SELECT * FROM olist_final_summary
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_full_summary_v2.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';