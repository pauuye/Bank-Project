create schema banking;

SELECT *
FROM bank;

SELECT *
FROM customer;


-- Altering the TransactionDate and JoinDate datatypes
ALTER TABLE customer
ADD COLUMN JoinDate_tmp DATE;

UPDATE customer
SET JoinDate_tmp = STR_TO_DATE(JoinDate, '%d/%m/%Y');

ALTER TABLE customer
DROP COLUMN JoinDate;

ALTER TABLE customer
CHANGE COLUMN TransactionDate JoinDate DATE;


-- Moving the TransactionDate next to CustomerID
ALTER TABLE bank 
MODIFY COLUMN TransactionDate DATE AFTER CustomerID;

-- Checking for duplicates
-- Bank Table duplicate check
WITH dupli as (SELECT *, ROW_NUMBER() OVER(PARTITION BY TransactionID, 
	CustomerID, TransactionDate, Amount, 
	Currency, PaymentMethod, 
	`Status`) as row_num
FROM bank)
SELECT *
FROM dupli
WHERE row_num > 1;

-- Customer Table duplicate check
WITH dupli as (SELECT *, ROW_NUMBER() OVER(PARTITION BY CustomerID, 
	FirstName, LastName, 
    Email, Phone, 
    Country, JoinDate) as row_num
FROM customer)
SELECT *
FROM dupli
WHERE row_num > 1;

-- END --

-- Double checking if the data is standardized
-- For Bank Table
SELECT *
FROM bank;

SELECT LENGTH(TransactionDate)
FROM bank
WHERE LENGTH(TransactionDate) > 10;

SELECT DISTINCT Currency
FROM bank;

SELECT DISTINCT Currency, LENGTH(Currency)
FROM bank;

SELECT DISTINCT PaymentMethod, LENGTH(PaymentMethod)
FROM bank;

-- END - Bank Table --

-- For Customer Table
SELECT *
FROM customer;

-- FirstName & LastName
SELECT DISTINCT LastName
FROM customer
WHERE LastName LIKE '% %';


SELECT LENGTH(Phone)
FROM customer
WHERE LENGTH(Phone) > 14;

SELECT Email
FROM customer
WHERE Email LIKE '% %';

-- City -- Country
SELECT DISTINCT Country
FROM customer;

-- Dropping City column as its not match with the country
ALTER table customer 
DROP column City;

-- END - Customer Table --

-- EDA

-- Most PaymentMethod used - Debit Card
SELECT PaymentMethod, COUNT(TransactionID) as transact_count
FROM bank
GROUP BY PaymentMethod
ORDER BY 2 DESC;

-- Customer Count 2000
SELECT  COUNT(CustomerID) as customer_count
FROM customer;

-- Countries with the most customers - USA
-- Top 3: USA, UK, & France
SELECT Country, COUNT(CustomerID)
FROM customer
GROUP BY Country
ORDER BY 2 DESC;


-- The number of new customers reached its minimum in 2022, then spiked upward in 2023 
SELECT YEAR(JoinDate) as `Year`, COUNT(CustomerID) as Join_Count
FROM customer
GROUP BY YEAR(JoinDate)
ORDER BY 1;

-- Breakdown of Total Count of Yearly new customers by Month
WITH monthly AS (SELECT YEAR(JoinDate) as `Year`, MONTH(JoinDate) as month_num, 
		DATE_FORMAT(JoinDate, '%M') as `Month`, COUNT(CustomerID) as Join_Count
FROM customer
GROUP BY YEAR(JoinDate), MONTH(JoinDate), DATE_FORMAT(JoinDate, '%M')
ORDER BY 1)
SELECT `Year`, `Month`, Join_Count
FROM monthly
ORDER by `Year`, month_num ASC
;

-- Determining the Average Transaction Status Rate by PaymentMethod
SELECT PaymentMethod,
    CONCAT(ROUND(AVG(`Status` = 'Completed')*100, 2), "%")  AS completed_rate,
    CONCAT(ROUND(AVG(`Status` = 'Pending')*100, 2), "%")   AS pending_rate,
    CONCAT(ROUND(AVG(`Status` = 'Failed')*100, 2), "%")  AS failed_rate
FROM bank
GROUP BY PaymentMethod
ORDER BY 2 DESC;

SELECT DISTINCT `Status`
FROM bank;

-- Daily Transactions
SELECT  YEAR(TransactionDate) as `Year`, DATE(TransactionDate) as transact_Date,
	COUNT(TransactionID) as transact_count
FROM bank
GROUP BY YEAR(TransactionDate), DATE(TransactionDate)
ORDER BY 1;

-- Monthly Transactions
WITH monthly AS (SELECT  YEAR(TransactionDate) as `Year`, 
		MONTH(TransactionDate) as month_num,
		DATE_FORMAT(TransactionDate, '%M') as Monthly,
		COUNT(TransactionID) as transact_count
FROM bank
GROUP BY YEAR(TransactionDate), 
	MONTH(TransactionDate), 
	DATE_FORMAT(TransactionDate, '%M')
ORDER BY 1)
SELECT `Year`, Monthly, transact_count
FROM monthly
ORDER BY `Year`, month_num ASC;

-- Yearly Transactions
SELECT  YEAR(TransactionDate) as `Year`,
	COUNT(TransactionID) as transact_count
FROM bank
GROUP BY YEAR(TransactionDate)
ORDER BY 1;

-- Total Count of Transaction Status by PaymentMethod and Countries
SELECT c2.Country, b1.PaymentMethod, 
	b1.`Status`, COUNT(b1.TransactionID) as transaction_count
FROM bank as b1
JOIN customer as c2
ON b1.CustomerID = c2.CustomerID
GROUP BY c2.Country, b1.PaymentMethod, b1.`Status`
ORDER BY 1, 2, 3 ASC, 4 DESC;

-- Analyze transaction performance per Country
-- Having the UK have the highest Completion Rate and France have the lowest completion rate
SELECT c2.Country,
    CONCAT(ROUND(AVG(b1.`Status` = 'Completed')*100, 1), "%")  AS completed_rate,
    CONCAT(ROUND(AVG(b1.`Status` = 'Pending')*100, 1), "%")   AS pending_rate,
    CONCAT(ROUND(AVG(b1.`Status` = 'Failed')*100, 1), "%")  AS failed_rate
FROM bank as b1
JOIN customer as c2
ON b1.CustomerID = c2.CustomerID
GROUP BY c2.Country
ORDER BY 1 ASC;

-- Analyze transaction performance per currency (completion, pending, and failure rates)
SELECT Currency,
    CONCAT(ROUND(AVG(`Status` = 'Completed')*100, 2), "%") AS completed_rate,
    CONCAT(ROUND(AVG(`Status` = 'Pending')*100, 2), "%")   AS pending_rate,
    CONCAT(ROUND(AVG(`Status` = 'Failed')*100, 2), "%")  AS failed_rate
FROM bank
GROUP BY Currency
ORDER BY 2 DESC;











