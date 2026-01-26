CREATE TABLE EXPENSES
(Expense_id INT AUTO_INCREMENT PRIMARY KEY,
Expense_date DATE,
Category VARCHAR(50),
Amount INT,
Payment_type VARCHAR(20)
);

INSERT INTO EXPENSES(Expense_date,Category,Amount,Payment_type)
VALUES('2026-01-01','Food',250,'Card'),
('2026-01-02','Transport',100,'Cash'),
('2026-01-03','Bills',500,'UPI'),
('2026-01-04','Food',300,'Cash'),
('2026-01-05','Shopping',400,'Card'),
('2026-01-06','Entertainment',150,'UPI'),
('2026-01-07','Food',200,'Card'),
('2026-01-08','Transport',120,'Cash'),
('2026-01-09','Bills',450,'Card'),
('2026-01-10','Food',180,'UPI');

-- Total Monthly expense (Metric)--
SELECT SUM(Amount) AS Total_monthly_expense
FROM Expenses;

-- Category wise expense(Metric)--
SELECT Category,SUM(Amount) AS Category_expenses
FROM Expenses
GROUP BY Category;

-- Highest spending category (KPI)--
SELECT Category,SUM(Amount) AS Category_expenses
FROM Expenses
GROUP BY Category
ORDER BY Category_expenses DESC LIMIT 1;

-- Average daily expense(Metric)--
SELECT ROUND(AVG(Amount),2) AS Avg_expenses 
FROM Expenses;

-- Number of transactions per category--
SELECT Category, COUNT(*) AS Transactions
FROM Expenses
GROUP BY Category;

-- Expense by Payment Method (Extra insight)--
SELECT Payment_type,SUM(Amount) AS Pay_Method_expense
FROM Expenses
GROUP BY Payment_type;

