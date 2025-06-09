CREATE DATABASE retail_sales;

-- Let's create the table of data
DROP TABLE IF EXISTS retail_sales;

# Firstly we will create a table with no values. We will set a columns in a text format. We do this because if for example we set a column as integer then the Null values
# in this column will re removed after we have just imported the data and we dont want this.

CREATE TABLE retail_sales (
			transactions_id TEXT,
			sale_date TEXT,
			sale_time TEXT,
			customer_id TEXT,
			gender TEXT,
			age TEXT,
			category TEXT,
			quantiy TEXT,
			price_per_unit TEXT,
			cogs TEXT, #this is the purchasing cost
			total_sale TEXT
);

-- Now import the data

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Retail Sales Analysis.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- We will check that we have imported all the rows from the csv file by counting them

SELECT COUNT(*)
FROM retail_sales;

# We are ok

-- Now, let's have a look of the data

SELECT *
FROM retail_sales;

-- Let's fix the name of a column

ALTER TABLE retail_sales RENAME COLUMN quantiy TO quantity;

-- Let's check for NULL values

-- We set all the columns as text columns and as a result all NULL values are represented as = "" and not as IS NULL

SELECT COUNT(*)
FROM retail_sales
WHERE transactions_id = "" OR
sale_date = "" OR
sale_time = "" OR
customer_id = "" OR
gender = "" OR
age = "" OR
category = "" OR
quantity = "" OR
price_per_unit = "" OR
cogs = "" OR
total_sale = "";

# So we have 13 rows out of 2000 which have a null value at least in one row.

-- Let's see more carefully the missing values and check if we can complete them

SELECT *
FROM retail_sales
WHERE transactions_id ="" OR
sale_date ="" OR
sale_time ="" OR
customer_id ="" OR
gender ="" OR
age ="" OR
category ="" OR
quantity ="" OR
price_per_unit ="" OR
cogs ="" OR
total_sale ="";

# We can't predict the age of a customer. So we can't fill these NULL values

# Also we can't fill any of the values in the columns quantity, price_per_unit, cogs, total_sale because as we can see there isn't any case where we can calculate one
# of them based on the others.

# So we can't fill any of these NULL values. Also the quantity of the rows which have null values related to the number of total rows is small. So we can exclude them.

DELETE
FROM retail_sales
WHERE transactions_id ="" OR
sale_date ="" OR
sale_time ="" OR
customer_id ="" OR
gender ="" OR
age ="" OR
category ="" OR
quantity ="" OR
price_per_unit ="" OR
cogs ="" OR
total_sale ="";

# Now we don't have any NULL values

SELECT *
FROM retail_sales;

-- Now it is time to change the data type of every column and put the right ones

ALTER TABLE retail_sales
MODIFY transactions_id INT;

UPDATE retail_sales
SET sale_date = STR_TO_DATE(sale_date, '%Y-%m-%d');

ALTER TABLE retail_sales
MODIFY COLUMN sale_date DATE;

ALTER TABLE retail_sales
MODIFY COLUMN sale_time TIME;

ALTER TABLE retail_sales
MODIFY customer_id INT;

ALTER TABLE retail_sales
MODIFY age INT;

ALTER TABLE retail_sales
MODIFY quantity INT;

ALTER TABLE retail_sales
MODIFY price_per_unit FLOAT;

ALTER TABLE retail_sales
MODIFY cogs FLOAT;

ALTER TABLE retail_sales
MODIFY total_sale FLOAT;

-- Let's see all the types

SHOW FIELDS
FROM retail_sales;

-- Let's go and see if there are duplicate values

WITH duplicate_CTE AS(

SELECT *,
ROW_NUMBER() OVER (PARTITION BY transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale) AS row_num
FROM retail_sales)

SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

-- As we can see we don't have any duplicates
    
-- Let's see the distinct values of every column
    
SELECT DISTINCT transactions_id
FROM retail_sales;

SELECT DISTINCT sale_date
FROM retail_sales;
    
SELECT DISTINCT sale_time
FROM retail_sales;

SELECT DISTINCT customer_id
FROM retail_sales;

SELECT DISTINCT gender
FROM retail_sales;

SELECT DISTINCT age
FROM retail_sales;

SELECT DISTINCT category
FROM retail_sales;

SELECT DISTINCT quantity
FROM retail_sales;

SELECT DISTINCT price_per_unit
FROM retail_sales;

SELECT DISTINCT cogs
FROM retail_sales;

SELECT DISTINCT total_sale
FROM retail_sales;

-- As we can see all the values seem ok

-- How many sales we have

SELECT COUNT(transactions_id)
FROM retail_sales;

-- How many customers do we have

SELECT COUNT(DISTINCT customer_id) AS num_of_customers
FROM retail_sales;

-- How many categories do we have

SELECT COUNT(DISTINCT category) AS categories
FROM retail_sales;

-- Let's see the categories

SELECT DISTINCT(category)
FROM retail_sales;

-- Let's answer some business questions

-- Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Write a SQL query to retrieve the total of transactions from the category Clothing in November 2022

SELECT category, SUM(total_sale)
FROM retail_sales
WHERE category = 'Clothing' AND
sale_date >= '2022-11-01' AND sale_date <= '2022-11-30'
GROUP BY category;

-- Write a SQL query to calculate the total sales for each category

SELECT category, SUM(total_sale)
FROM retail_sales
GROUP BY category;

-- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category

SELECT AVG(age)
FROM retail_sales
WHERE category = 'Beauty';

-- Write a SQL query to find all transactions where total_sale is greater than 1000

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category

SELECT gender, category, COUNT(*) AS total_transacations
FROM retail_sales
GROUP BY gender, category;

-- Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH average_cte AS(

SELECT DATE_FORMAT(sale_date, '%Y-%m') AS year_and_month,
ROUND(AVG(total_sale), 2) AS Average_Sale
FROM retail_sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')

)

SELECT *,
RANK() OVER( PARTITION BY(SUBSTRING(year_and_month,1,4)) ORDER BY Average_Sale DESC ) AS Ranking
FROM average_cte
ORDER BY Ranking
;

# So the best month for 2022 was the July and the best month for 2023 was Febuary

-- Write a SQL query to find the top 5 customers based on the highest total sales

SELECT customer_id,
SUM(total_sale) AS total_sale_per_customer
FROM retail_sales
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 5
;

-- Write a SQL query to find the number of unique customers who purchased items for each category

SELECT category, COUNT(DISTINCT(customer_id)) AS count_unique_customers
FROM retail_sales
GROUP BY category
;

-- Write a SQL query to create each shift and number of orders (Example: Morning <= 12, Afternoon Between 12 and 17, Evening > 17

SELECT shift, COUNT(shift)
FROM
(
SELECT *,
CASE
	WHEN sale_time <= '12:00:00' THEN 'Morning'
    WHEN sale_time > '12:00:00' AND sale_time <= '17:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END AS shift
FROM retail_sales
) AS a
GROUP BY shift
;
