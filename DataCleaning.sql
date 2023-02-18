USE db;

SELECT * FROM marketing_campaign;

-- create column to store customer age
ALTER TABLE marketing_campaign
ADD Age	NUMERIC;

-- update created column with calculated values(year of customer's enrollment with the company - Year of birth)
UPDATE marketing_campaign
SET Age = CAST(SUBSTRING(Dt_Customer,7,LEN(Dt_Customer)) AS INT) - Year_Birth;

SELECT ID, Age FROM marketing_campaign Order by Age

-- Create column to Store age groupd
ALTER TABLE marketing_campaign
ADD Age_Group varchar(255)


--Update created column with new values to make customer's age more usable to analyze our data
UPDATE marketing_campaign
SET Age_Group = CASE WHEN Age<31 THEN 'Adolecent'
WHEN Age>30 AND Age<55 THEN 'Middle Age'
WHEN Age>54 THEN 'Old' 
END

SELECT Age, Age_Group
FROM marketing_campaign
ORDER BY Age

--Delete column Age because we don't need it any more, so we keep our database smaller
ALTER TABLE marketing_campaign
DROP COLUMN Age

SELECT * FROM marketing_campaign
WHERE Marital_Status='YOLO'

--remove duplicates
WITH Row_num AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY Year_Birth,
					 Education,
					 Marital_Status,
					 Income,
					 Dt_Customer,
					 MntWines
					 ORDER BY ID
	)row_num

FROM marketing_campaign
)
DELETE FROM Row_num
WHERE row_num>1


UPDATE marketing_campaign
SET Marital_Status = Case Marital_Status WHEN 'Alone' THEN 'Single'
	WHEN 'Absurd' THEN 'Single'
	WHEN 'YOLO' THEN 'Single'
	ELSE Marital_Status
	END

-- fill empty cells in Income column with average income calculated by education
WITH Avg_Income AS(
SELECT Education, AVG(CAST(Income AS INT)) as Average_Income
FROM marketing_campaign
GROUP BY Education
)
UPDATE marketing_campaign
SET Income=Avg_Income.Average_Income
FROM Avg_Income
WHERE marketing_campaign.Income=0 AND marketing_campaign.Education = Avg_Income.Education


--find the best/worst selling product

CREATE TABLE #total_sales(
	Product_Type VARCHAR(50),
	Sold NUMERIC
)

INSERT INTO #total_sales(Product_Type) VALUES
('wine'), ('fruit'), ('meat'), ('fish'), ('sweets'), ('gold')


WITH sum_sales AS(
SELECT SUM(MntWines) as wine,SUM(MntFruits) as fruit, SUM(MntMeatProducts) as meat, SUM(MntFishProducts) as fish,
SUM(MntSweetProducts) as sweet, SUM(MntGoldProds) as gold
FROM marketing_campaign
)
UPDATE #total_sales
SET Sold = CASE Product_Type WHEN 'wine' THEN wine
WHEN 'fruit' THEN fruit WHEN 'meat' THEN meat
WHEN 'fish' THEN fish WHEN 'sweets' THEN sweet
WHEN 'gold' THEN gold
END
FROM sum_sales

SELECT * FROM #total_sales


-- the best selling product
SELECT TOP 1 Product_Type, Sold FROM #total_sales
ORDER BY Sold DESC

-- the worst selling product
SELECT TOP 1 Product_Type, Sold FROM #total_sales
ORDER BY Sold

-- which place do customers purchse more products
CREATE TABLE #place(
	place VARCHAR(50),
	amount NUMERIC
)
INSERT INTO #place(place) VALUES
('web'), ('catalog'), ('store')


WITH amount_sold AS(
SELECT SUM(NumWebPurchases) as sum_web, SUM(NumCatalogPurchases) as sum_catalog, SUM(NumStorePurchases) as sum_store
FROM marketing_campaign
)
UPDATE #place
SET amount = CASE place WHEN 'web' THEN sum_web
	WHEN 'catalog' THEN sum_catalog
	WHEN 'store' THEN sum_store
	END
FROM amount_sold

SELECT * FROM #place


SELECT Marital_Status, SUM(MntWines) as Wine, SUM(MntFruits) as fruits, SUM(MntFishProducts) as fish,
SUM(MntMeatProducts) as meat, SUM(MntSweetProducts) as sweets, SUM(MntGoldProds) as Gold
FROM marketing_campaign
GROUP BY Marital_Status ORDER BY Marital_Status

-- see who spends more money by marital status, graduation and income
SELECT Marital_Status, Education, AVG(MntWines)+ AVG(MntFruits) + AVG(MntFishProducts) + 
AVG(MntMeatProducts) + AVG(MntSweetProducts) + AVG(MntGoldProds) as Spent, CAST(AVG(Income) AS INT) as Avg_Income
FROM marketing_campaign
GROUP BY Marital_Status, Education
ORDER BY Avg_Income DESC

SELECT Education, MntFishProducts,MntFruits,MntGoldProds, MntMeatProducts, MntSweetProducts,MntWines FROM marketing_campaign
WHERE Education='Master' and Marital_Status='Widow'
--GROUP BY Education

--remove unused columns
ALTER TABLE marketing_campaign
DROP COlUMN Z_CostContact, Z_Revenue