/*
Data Exploration
*/
DESC customer;
DESC orderdetail;
DESC orders;
DESC product;

/*
Q1.	Identify the top 3 cities with the highest number of customers 
	to determine key markets for targeted marketing and logistic optimization.
*/
SELECT location AS city_name, COUNT(customer_id) AS number_of_customers
FROM customer
GROUP BY location
ORDER BY  number_of_customers DESC
LIMIT 3;

/*
Q2. Determine the distribution of customers by the number of orders placed. 
*/

WITH order_count AS (
SELECT Customer_id,COUNT(order_id) AS NumberOfOrders
FROM Orders
GROUP BY Customer_id
)
SELECT NumberOfOrders,COUNT(Customer_id) AS NoOfCustomers
FROM order_count
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders ASC;

/*
Q3. Determine the distribution of customers within segments as one-time buyers, 
	occasional shoppers, and regular customers for tailored marketing strategies.
	e.g. for NumberOfOrders 1='One-time buyer',NumberOfOrders 2-4='Occasional shoppers',NumberOfOrders >4='Regular Customer'
*/

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

/*
Q4. Identify products where the average purchase quantity per order is 2 
	but with a high total revenue, suggesting premium product trends.
*/

SELECT product_id, ROUND(AVG(quantity),0) AS AVG_Purchase_Quantity, SUM(quantity*price_per_unit) AS total_revenue
FROM orderdetail
GROUP BY product_id
HAVING AVG(quantity)=2
ORDER BY total_revenue DESC;

/*
Q5. For each product category, calculate the unique number of customers purchasing from it. 
	This will help understand which categories have wider appeal across the customer base
*/

SELECT category, COUNT(DISTINCT customer_id) AS NoOfCustomers
FROM product p
JOIN orderdetail d
ON p.product_id=d.product_id
JOIN orders o
ON d.order_id=o.order_id
GROUP BY category
ORDER BY NoOfCustomers DESC;

/*
Q6. Analyze the month-on-month percentage change in total sales to identify growth trends.
*/
WITH MonthlySale AS
(SELECT DATE_FORMAT (STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month)
SELECT  Month,TotalSales,
ROUND(100*(TotalSales-LAG(TotalSales) OVER (ORDER BY Month ASC))/LAG(TotalSales) OVER (ORDER BY Month ASC),2) AS PercentChange
FROM MonthlySale
GROUP BY Month,TotalSales;

/*
Q7. Examine how the average order value changes month-on-month. 
	Insights can guide pricing and promotional strategies to enhance order value.
*/

SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month,ROUND(AVG(total_amount),2) AS AvgOrderValue,
ROUND(AVG(total_amount)- LAG(AVG(total_amount)) OVER (ORDER BY DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')),2) AS ChangeInValue
FROM Orders
GROUP BY Month
ORDER BY ChangeInValue DESC;

/*
Q8. Based on sales data, identify top 5 products with the fastest turnover rates,
	suggesting high demand and the need for frequent restocking.
*/
SELECT Product_id,COUNT(order_id) AS SalesFrequency
FROM OrderDetail
GROUP BY Product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

/*
Q9. List products purchased by less than 40% of the customer base,
	indicating potential mismatches between inventory and customer interest.
*/

SELECT p.Product_id,p.Name,COUNT(Distinct o.customer_id) AS UniqueCustomerCount
FROM Product p
JOIN OrderDetail d
ON p.Product_id=d.Product_id
JOIN Orders o
ON d.Order_id=o.Order_id
Group by p.Product_id,p.Name
Having COUNT(DISTINCT o.customer_id) <(SELECT COUNT(*) FROM customer)*0.4;

/* 
Q10. Evaluate the month-on-month growth rate in the customer base 
	to understand the effectiveness of marketing campaigns and market expansion efforts
*/

WITH firstPurchase AS (
SELECT Customer_id, MIN(DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')) AS firstmonth
FROM Orders
GROUP BY Customer_id)
SELECT firstmonth AS FirstPurchaseMonth, COUNT(Customer_id) AS TotalNewCustomers
FROM firstPurchase
GROUP BY firstmonth
ORDER BY firstmonth ASC;

/*
Q11. Identify top 3 months with the highest sales volume, 
	aiding in planning for stock levels, marketing efforts, 
	and staffing in anticipation of peak demand periods.
*/
SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY DATE_FORMAT(STR_TO_DATE(order_date,'%Y-%m-%d'),'%Y-%m')
ORDER BY TotalSales DESC
LIMIT 3;
