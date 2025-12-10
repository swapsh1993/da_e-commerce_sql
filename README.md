# da_e-commerce_sql
The project includes details of an E-commerce company like customers, orders, products and order details. In this project Exploratory Data Analysis and Business problem solution have been done to get insights of questions using SQL.
•	**Project Title** – da_e-commerce_sql

•	**Brief Summery** – The project includes details of an E-commerce company like customers, orders, products and order details. In this project Exploratory Data Analysis and Business problem solution have been done to get insights of questions using SQL.

•	**Objective –**
1.	**Set up a database:** Create and populate an e-commerce_company_retail_analysis database with the provided dataset.
   
2.	**Exploratory Data Analysis (EDA):** Perform basic exploratory data analysis to understand the dataset. Identify to remove any records with missing or null values.
   
3.	**Business Analysis:** Use SQL to answer specific business questions and derive insights from the sales data.
   
•	**Problem Statement –** 
The project involves setting up an e-commerce_company_retail_analysis database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. The questions are as follows:
1.	Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
2.	Determine the distribution of customers by the number of orders placed. 
3.	Determine the distribution of customers within segments as one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies. e.g. for NumberOfOrders 1='One-time buyer', NumberOfOrders 2-4='Occasional shoppers', NumberOfOrders >4='Regular Customer'.
4.	Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
5.	For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.
6.	Analyze the month-on-month percentage change in total sales to identify growth trends.
7.	Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
8.	Based on sales data, identify top 5 products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
9.	List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
10.	Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
11.	Identify top 3 months with the highest sales volume, aiding in planning for stock levels, marketing efforts and staffing in anticipation of peak demand periods.
    
•	**Dataset** – Dataset in CSV contains information about customer, orderdetail, orders, and product in data tables.

•	**Tools and Technologies** – Here I have used MySQL for developing the project which includes EDA and SQL queries to answer questions from problem statement.

•	**Data Analysis –**

**1. Data Exploration –**
Task: Describe the Tables:

***SQL
DESC customer;
DESC orderdetail;
DESC orders;
DESC product;
***

**2.	Exploratory Data Analysis –**
a. Record Count: Determine the total number of records in the dataset.

***
SELECT COUNT(*) FROM customer;

SELECT COUNT(*) FROM orderdetail;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM product;
***

b. Customer Count: Find out how many unique customers are in the dataset.

***sql
SELECT COUNT(DISTINCT customer_id) FROM customer;
***

c. Null Value Check: Check for any null values in the dataset

***sql
SELECT * FROM Customer
WHERE 
	customer_id IS NULL OR
    name IS NULL OR
    location IS NULL;

SELECT * FROM orderdetail
WHERE 
	order_id IS NULL OR
    product_id IS NULL OR
    quantity IS NULL OR
    price_per_unit IS NULL;

SELECT * FROM orders
WHERE 
	order_id IS NULL OR
    order_date IS NULL OR
    customer_id IS NULL OR
    total_amount IS NULL;

SELECT * FROM product
WHERE 
	product_id IS NULL OR
    name IS NULL OR
    category IS NULL OR
    price IS NULL;
***

**3.	SQL queries to solve business problems**

Q1. Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

***sql
SELECT location AS city_name, COUNT(customer_id) AS number_of_customers
FROM customer
GROUP BY location
ORDER BY  number_of_customers DESC
LIMIT 3;
***

Q2. Determine the distribution of customers by the number of orders placed. 

***sql
WITH order_count AS (
SELECT Customer_id,COUNT(order_id) AS NumberOfOrders
FROM Orders
GROUP BY Customer_id
)
SELECT NumberOfOrders,COUNT(Customer_id) AS NoOfCustomers
FROM order_count
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders ASC;
***

Q3. Determine the distribution of customers within segments as one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies. e.g. for NumberOfOrders         1='One-time buyer', NumberOfOrders 2-4='Occasional shoppers', NumberOfOrders >4='Regular Customer'.

***sql
WITH order_count AS (
SELECT Customer_id,COUNT(order_id) AS NumberOfOrders,
CASE
    WHEN COUNT(order_id) >4 THEN 'Regular customers'
    WHEN COUNT(order_id)=1 THEN 'One-time buyers'
    ELSE 'Occasional Shoppers'
    END AS Terms
FROM Orders
GROUP BY Customer_id
)
SELECT Terms,COUNT(Customer_id) AS NoOfCustomers
FROM order_count
GROUP BY Terms
ORDER BY NoOfCustomers DESC;
***

Q4. Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

***sql
SELECT product_id, ROUND(AVG(quantity),0) AS AVG_Purchase_Quantity, SUM(quantity*price_per_unit) AS total_revenue
FROM orderdetail
GROUP BY product_id
HAVING AVG(quantity)=2
ORDER BY total_revenue DESC;
***

Q5. For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

***sql
SELECT category, COUNT(DISTINCT customer_id) AS NoOfCustomers
FROM product p
JOIN orderdetail d
ON p.product_id=d.product_id
JOIN orders o
ON d.order_id=o.order_id
GROUP BY category
ORDER BY NoOfCustomers DESC;
***

Q6. Analyze the month-on-month percentage change in total sales to identify growth trends.

***sql
WITH MonthlySale AS
(SELECT DATE_FORMAT (STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month)
SELECT  Month,TotalSales,
ROUND(100*(TotalSales-LAG(TotalSales) OVER (ORDER BY Month ASC))/LAG(TotalSales) OVER (ORDER BY Month ASC),2) AS PercentChange
FROM MonthlySale
GROUP BY Month,TotalSales;
***

Q7. Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

***sql
SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month,ROUND(AVG(total_amount),2) AS AvgOrderValue,
ROUND(AVG(total_amount)- LAG(AVG(total_amount)) OVER (ORDER BY DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')),2) AS ChangeInValue
FROM Orders
GROUP BY Month
ORDER BY ChangeInValue DESC;
***

Q8. Based on sales data, identify top 5 products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

***sql
SELECT Product_id,COUNT(order_id) AS SalesFrequency
FROM OrderDetail
GROUP BY Product_id
ORDER BY SalesFrequency DESC
LIMIT 5;
***

Q9. List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

***sql
SELECT p.Product_id,p.Name,COUNT(Distinct o.customer_id) AS UniqueCustomerCount
FROM Product p
JOIN OrderDetail d
ON p.Product_id=d.Product_id
JOIN Orders o
ON d.Order_id=o.Order_id
Group by p.Product_id,p.Name
Having COUNT(DISTINCT o.customer_id) <(SELECT COUNT(*) FROM customer)*0.4;
***

Q10. Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

***sql
WITH firstPurchase AS (
SELECT Customer_id, MIN(DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')) AS firstmonth
FROM Orders
GROUP BY Customer_id)
SELECT firstmonth AS FirstPurchaseMonth, COUNT(Customer_id) AS TotalNewCustomers
FROM firstPurchase
GROUP BY firstmonth
ORDER BY firstmonth ASC;
***

Q11. Identify top 3 months with the highest sales volume, aiding in planning for stock levels, marketing efforts and staffing in anticipation of peak demand periods.

***sql
SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')
ORDER BY TotalSales DESC
LIMIT 3;
***

•	Result – The findings from this project are as follows:
1.	Delhi, Chennai and Jaipur are the cities must be focused as a part of marketing strategies
2.	The trend of the number of customers v/s number of orders shows: As the number of orders increases, the customer count decreases.
3.	Occasional shoppers is the customers category that the company experiences the most
4.	Product 1 exhibit the highest total revenue from products with average purchase quantity per order 2, which is 1620000
5.	‘Electronics’ is the product category which needs more focus as it is in high demand among the customers.
6.	December month has the highest change in the average order value
7.	product_id 7 has the highest turnover rates and needs to be restocked frequently.
8.	September and December months will require major restocking of product and increased staffs
   
•	Conclusion – 
This project covers database setup, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

•	How to run this project – 
Step 1 – Clone the Repository: Clone this project repository from GitHub.
Step 2 – Set Up the Database: Run the SQL scripts provided in the E-commerce.sql file to create and populate the database.
Step 3 – Run the Queries: Use the SQL queries provided in the E-commerce.sql file to perform your analysis.
Step 4 - Explore and Modify: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions

•	Author & contact – Swapnil Shinde, Email ID – swapsh1993@yahoo.in
