CREATE DATABASE sql_project_p1;

USE sql_project_p1;

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );
            
SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) 
FROM retail_sales;

-- DATA CLEANING
SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- DATA EXPLORATION

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;

-- DATA ANALYSIS AND BUSINESS KEY PROBLEM & ANSWERS

-- Retrieving all sales made on 2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Retrieving 'Clothing' transactions with quantity > 4 in November 2022

SELECT *
FROM retail_sales
WHERE
	category = 'Clothing'
    AND
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
    AND
    quantity >= 4;

-- Calculating total sales (total_sale) for each category

SELECT
	category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1;

-- Calculating average age of customers who purchased from the 'Beauty' category

SELECT
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Retrieving transactions with total_sale greater than 1000

SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Retrieving first and last purchase dates for each customer

SELECT customer_id,
       MIN(sale_date) AS first_purchase,
       MAX(sale_date) AS last_purchase
FROM retail_sales
GROUP BY customer_id;

-- Counting total number of transactions by gender and category

SELECT
	gender,
    category,
    count(*) AS total_trans
FROM retail_sales
GROUP BY 1, 2
ORDER BY 2, 3;

-- Counting number of orders for each day of the week

SELECT 
	DAYNAME(sale_date) AS day_of_week,
    COUNT(*) AS orders
FROM retail_sales
GROUP BY day_of_week
ORDER BY 2;

-- Calculating the average sale for each month and identifying the best-selling month in each year

SELECT
	year,
    month,
    avg_sale
FROM 
(
SELECT
	YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    AVG(total_sale) AS avg_sale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS ranks
FROM retail_sales
GROUP BY 1, 2
) AS t1
WHERE ranks = 1;

-- Finding top 5 customers based on highest total sales 

SELECT 
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Counting unique customers who purchased from each category

SELECT
	category,
    COUNT(DISTINCT customer_id) unq_cust_id
FROM retail_sales
GROUP BY category;

-- Creating order shifts and counting number of orders in each shift

WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM retail_sales
)
SELECT 
	shift,
    COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift;

-- Identifying customers with more than 3 purchases in a month

SELECT
	customer_id,
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    COUNT(*) AS purchase
FROM retail_sales
GROUP BY 1, 2
HAVING purchase > 3;

-- Classifying customers as repeat or one-time based on purchase count

SELECT
	customer_id,
    COUNT(*) AS purchase_count,
    CASE
		WHEN COUNT(*) > 1 THEN 'repeater'
        ELSE 'one-timer'
	END AS customer_type
FROM retail_sales
GROUP BY customer_id;
