Create table Zepto
(sku_id INT PRIMARY KEY AUTO_INCREMENT,
category VARCHAR(150),
name VARCHAR(120) NOT NULL,
mrp DECIMAL(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

-- DATA EXPLORATION:-

SELECT  * FROM Zepto limit 10;

-- null values across all columns:-
SELECT * FROM Zepto 
where category is NULL
OR
name is NULL
OR 
mrp is NULL
OR 
discountPercent is NULL
OR 
availableQuantity is NULL
OR
discountedSellingPrice is NULL
OR
weightInGms is NULL
OR
outOfStock is NULL
OR 
quantity is NULL;

-- Different product category:--
SELECT DISTINCT category FROM Zepto
ORDER BY category;

-- products in stock vs out of stock--
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock; 

-- products name which are present more than once in sku id--
SELECT name, COUNT(sku_id) as "No.of Skus"
FROM Zepto
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING----

-- products having price 0-- 
SELECT * FROM Zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM Zepto WHERE mrp= 0;

-- Convert paise into rupee--
UPDATE Zepto
SET mrp= mrp/100 ,
discountedSellingPrice = discountedSellingPrice/100;

SELECT mrp,discountedSellingPrice FROM Zepto;

-- BUSINESS INSIGHTS---
-- 1)Find the top 10 best-value products based on discount percentage--
SELECT DISTINCT name, mrp,discountPercent FROM Zepto
ORDER BY discountPercent DESC LIMIT 10;

-- 2)Identified high-MRP products that are currently out of stock
SELECT  DISTINCT name,mrp from zepto
where outOfStock = 1 AND mrp>300
order by mrp desc;

-- 3) Calculated Estimated revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) as total_revenue
from Zepto
GROUP BY category
ORDER BY total_revenue;

-- 4)Find all products where mrp >500 and discount is less than 10%
SELECT DISTINCT name,mrp,discountPercent
FROM Zepto 
WHERE mrp>500 and discountPercent<10
ORDER BY mrp DESC, discountPercent DESC;

-- 5) Identify the top 5 categories offering the highest average discount percentage
SELECT category,
ROUND(AVG(discountPercent),2 )AS Avg_discount 
FROM ZEPTO
GROUP BY category
ORDER BY Avg_discount DESC
LIMIT 5;

-- 6) Find the price per gram for products above 100g and sort by best value
SELECT DISTINCT name,weightInGms,discountedSellingPrice,
ROUND((discountedSellingPrice/weightInGms),2) AS price_per_gram
FROM Zepto 
WHERE weightInGms>=100 
ORDER BY price_per_gram;
 
-- 7) Group the products into categories like Low,Medium,Bulk.
SELECT DISTINCT name,weightInGms,
CASE WHEN weightInGms <1000 THEN 'LOW' 
WHEN weightInGms <5000 THEN 'MEDIUM'
ELSE 'BULK'
END AS weight_category
FROM Zepto;

-- 8) What is the total inventory weight per category
SELECT category,
SUM(weightInGms * availableQuantity) AS Total_inventory_weight
FROM Zepto
GROUP BY category
ORDER BY Total_inventory_weight;











 
 







