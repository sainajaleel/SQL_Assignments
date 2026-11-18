-- Impute missing values using mean
SELECT
    AVG(WarehouseToHome) AS Avg_WarehouseToHome,
    SUM(WarehouseToHome IS NULL) AS Missing_WarehouseToHome,
    AVG(HourSpendOnApp) AS Avg_HourSpendOnApp,
    SUM(HourSpendOnApp IS NULL) AS Missing_HourSpendOnApp,
    AVG(OrderAmountHikeFromlastYear) AS Avg_OrderAmountHike,
    SUM(OrderAmountHikeFromlastYear IS NULL) AS Missing_OrderAmountHike,
    AVG(DaySinceLastOrder) AS Avg_DaySinceLastOrder,
    SUM(DaySinceLastOrder IS NULL) AS Missing_DaySinceLastOrder
FROM customer_churn;

UPDATE customer_churn
SET
    WarehouseToHome = COALESCE(WarehouseToHome, 16),
    HourSpendOnApp = COALESCE(HourSpendOnApp, 3),
    OrderAmountHikeFromlastYear = COALESCE(OrderAmountHikeFromlastYear, 16),
    DaySinceLastOrder = COALESCE(DaySinceLastOrder, 5)
WHERE CustomerID > 0;

-- Impute missing values using mode
SELECT 'Tenure' AS Column_Name, Tenure AS Mode_Value, COUNT(*) AS Frequency
FROM customer_churn
WHERE Tenure IS NOT NULL
GROUP BY Tenure
ORDER BY Frequency DESC
LIMIT 1;

SELECT CouponUsed AS Mode_Value, COUNT(*) AS Frequency
FROM customer_churn
WHERE CouponUsed IS NOT NULL
GROUP BY CouponUsed
ORDER BY Frequency DESC
LIMIT 1;

SELECT OrderCount AS Mode_Value, COUNT(*) AS Frequency
FROM customer_churn
WHERE OrderCount IS NOT NULL
GROUP BY OrderCount
ORDER BY Frequency DESC
LIMIT 1;

UPDATE customer_churn
SET
    Tenure = COALESCE(Tenure, 1),
    CouponUsed = COALESCE(CouponUsed, 1),
    OrderCount = COALESCE(OrderCount, 2)
WHERE CustomerID > 0;

SELECT
    SUM(Tenure IS NULL) AS Missing_Tenure,
    SUM(CouponUsed IS NULL) AS Missing_CouponUsed,
    SUM(OrderCount IS NULL) AS Missing_OrderCount
FROM customer_churn;

-- Delete rows where WarehouseToHome > 100
SELECT COUNT(*) AS Rows_To_Delete
FROM customer_churn
WHERE WarehouseToHome > 100;

DELETE FROM customer_churn
WHERE WarehouseToHome > 100
AND CustomerID > 0;

-- Replace Phone and Mobile with Mobile Phone
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone'
AND CustomerID > 0;

UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile'
AND CustomerID > 0;

-- Standardize payment mode values
UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD'
AND CustomerID > 0;

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC'
AND CustomerID > 0;

-- Rename PreferedOrderCat and HourSpendOnApp columns
ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

--  Create ComplaintReceived column
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3);

UPDATE customer_churn
SET ComplaintReceived = CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END
WHERE CustomerID > 0;

-- Create ChurnStatus column
ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(10);

UPDATE customer_churn
SET ChurnStatus = CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END
WHERE CustomerID > 0;

-- Drop Churn and Complain columns
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

-- number of churned and active customers
SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;

-- average tenure and total cashback of churned customers
SELECT
    AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- percentage of churned customers who complained
SELECT
    (SUM(ComplaintReceived = 'Yes') / COUNT(*)) * 100
    AS ComplaintPercentage
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- city tier with the highest number of churned customers who prefer the Laptop & Accessory category
SELECT CityTier, COUNT(*) AS ChurnedCustomers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCustomers DESC
LIMIT 1;

-- most preferred payment mode among active customers
SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;

-- total order amount hike from last year for single customers who prefer mobile phones
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
AND PreferredOrderCat = 'Mobile Phone';

-- average number of devices registered by customers who prefer UPI
SELECT AVG(NumberOfDeviceRegistered) AS AverageDevices
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- city tier with the highest number of customers
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

-- gender that utilized the highest number of coupons
SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;

-- number of customers and maximum hours spent on the app in each preferred order category
SELECT
    PreferredOrderCat,
    COUNT(*) AS CustomerCount,
    MAX(HoursSpentOnApp) AS MaxHoursSpent
FROM customer_churn
GROUP BY PreferredOrderCat;

-- total order count of customers who prefer Credit Card and have the maximum satisfaction score
SELECT SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- average satisfaction score of customers who complained
SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- preferred order category among customers who used more than 5 coupons
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC
LIMIT 1;

-- top 3 preferred order categories with the highest average cashback amount
SELECT 
    PreferredOrderCat, AVG(CashbackAmount) AS AverageCashback
FROM
    customer_churn
GROUP BY PreferredOrderCat
ORDER BY AverageCashback DESC
LIMIT 3;

-- preferred payment modes of customers whose average tenure is 10 months and who have placed more than 500 orders
SELECT DISTINCT PreferredPaymentMode
FROM customer_churn
WHERE Tenure = 10
AND OrderCount > 500;

-- customers by their WarehouseToHome distance and the churn status breakdown
SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory;

-- order details of married customers living in City Tier 1 whose order count is above the average order count
SELECT * FROM customer_churn
WHERE MaritalStatus = 'Married'
AND CityTier = 1
AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);

-- Create a customer_returns table
CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);
 
 -- Inserting data
INSERT INTO customer_returns
(ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

-- return and customer details for churned customers who made complaints
SELECT * FROM customer_returns r
INNER JOIN customer_churn c
ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
AND c.ComplaintReceived = 'Yes';

