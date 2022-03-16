-- CORRECT HOMEWORK LESSON 4 -- 

-- GROUP BY: 

/*1: From DimEmployee 
Display the total number of employees in each DepartmentName. Then only show departments having more than 7 members. */ 

-- Your code here 

SELECT 
    DepartmentName
    , COUNT( EmployeeKey) AS total_number_employees
FROM 
    DimEmployee
GROUP BY DepartmentName 
HAVING COUNT(EmployeeKey) > 7
ORDER BY total_number_employees DESC
 

/*2: From FactInternetSales, DimCustomer, DimGeography,  
Displaying CustomerKey, FullName (combine FirstName, MiddleName, LastName) and sum of SalesAmount  
by each customer who has yearly income > 150000 and come from United States */ 

-- Your code here 
-- Kiểm tra xem 1 Customer có bao nhiêu đơn hàng
SELECT TOP 5
    CustomerKey
    , COUNT(DISTINCT  SalesOrderNumber) AS nb_orders
FROM FactInternetSales
GROUP BY CustomerKey
ORDER BY nb_orders DESC

SELECT * FROM FactInternetSales WHERE CustomerKey = 11176 
-- way 1
SELECT 
    inter.CustomerKey
    , CONCAT_WS(' ', FirstName, MiddleName, LastName) AS FullName
    -- , EnglishCountryRegionName
    -- , YearlyIncome
    , SUM(SalesAmount) AS total_sales_amount
FROM FactInternetSales AS inter
JOIN DimCustomer AS cus
ON inter.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo
ON cus.GeographyKey = geo.GeographyKey
WHERE YearlyIncome > 150000
AND EnglishCountryRegionName = 'United States'
GROUP BY 
    inter.CustomerKey
    , CONCAT_WS(' ', FirstName, MiddleName, LastName)
    -- , EnglishCountryRegionName
    -- , YearlyIncome

-- way 2
SELECT 
    join_table.CustomerKey
    , total_sale_amount
    , CONCAT_WS(' ', FirstName, MiddleName, LastName) AS FullName
    , EnglishCountryRegionName
    , YearlyIncome
FROM (Select CustomerKey, SUM(SalesAmount) AS total_sale_amount -- có 18484 customers
        FROM FactInternetSales
        GROUP BY CustomerKey
        ) AS join_table
JOIN DimCustomer AS cus
ON join_table.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo
ON cus.GeographyKey = geo.GeographyKey 
WHERE YearlyIncome > 150000
AND EnglishCountryRegionName = 'United States'
 

/*3: From FactInternetSales, DimProduct, DimProductSubcategory and DimProductCategory,  
Write a query displaying the EnglishProductCategoryName with the following metrics:  
The total number of orders (count of SalesOrderNumber) 
The maximum value of SalesAmount 
The minimum value of SalesAmount 
The average value of TotalProductCost */ 

-- output: EnglishProductCategoryName, total_orders, max_amount, min_amount, avg_cost
-- kiểm tra xem SalesOrderNumber có unique không?
SELECT COUNT(*), COUNT(DISTINCT SalesOrderNumber)  FROM FactInternetSales

SELECT TOP 20 * 
FROM FactInternetSales
WHERE SalesOrderNumber = 'SO58845' 
ORDER BY SalesOrderLineNumber DESC

-- Đáp án
SELECT
    EnglishProductCategoryName
    , COUNT(DISTINCT SalesOrderNumber) AS total_orders
    , MAX(SalesAmount) AS max_amount
    , MIN(SalesAmount) AS min_amount
    , AVG(TotalProductCost) AS avg_cost 
FROM FactInternetSales inter 
LEFT JOIN DimProduct pro 
    ON inter.ProductKey = pro.ProductKey
LEFT JOIN DimProductSubcategory sub 
    ON pro.ProductSubcategoryKey = sub.ProductSubcategoryKey 
LEFT JOIN DimProductCategory cat 
    ON sub.ProductCategoryKey = cat.ProductCategoryKey
GROUP BY EnglishProductCategoryName 

-- CTE và WINDOWN FUNCTION 

/*4: Find out 5 SaleOrderNumber with highest SalesAmount in InternetSales table (Use RANK() ) */ 

SELECT COUNT(*), COUNT(DISTINCT c)  FROM FactInternetSales

-- way 1: GROUP BY theo SaleOrderNumber, tính SUM of SalesAmount và sau đó chọn top 5 

SELECT TOP 5
    SalesOrderNumber
    , SUM(SalesAmount) total_amount
FROM FactInternetSales
GROUP BY SalesOrderNumber
ORDER BY total_amount DESC

-- way 2: 
SELECT DISTINCT TOP 5 
    SalesOrderNumber
    , SUM(SalesAmount) OVER(PARTITION BY SalesOrderNumber) AS total_amount_by_order
FROM FactInternetSales
-- WHERE SalesOrderNumber IN ('SO58845', 'SO70714') 
ORDER BY total_amount_by_order DESC

-- way 3: 

WITH temp_table AS (
    SELECT 
        SalesOrderNumber
        , SUM(SalesAmount) total_amount
    FROM FactInternetSales
    GROUP BY SalesOrderNumber
)
SELECT TOP 5
    *
    , RANK() OVER( ORDER BY total_amount DESC) AS rn
FROM temp_table 
ORDER BY rn

-- 
/*5: Find out 5 SaleOrderNumber with highest SalesAmount in each month from FactInternetSales tables (Use RANK() + PARTITION BY) */ 

SELECT TOP 5 * FROM FactInternetSales

WITH amount_by_month AS (
SELECT 
    MONTH(OrderDate) AS calendar_month
    , YEAR(OrderDate) AS calendar_year 
    , SalesOrderNumber
    , SUM(SalesAmount) total_amount
FROM FactInternetSales
GROUP BY MONTH(OrderDate)
    , YEAR(OrderDate)
    , SalesOrderNumber
-- ORDER BY calendar_year, calendar_month
), 
rank_table AS (
SELECT * 
    , ROW_NUMBER() OVER (PARTITION BY calendar_year, calendar_month ORDER BY total_amount DESC ) AS rankcolumn
FROM amount_by_month 
)
SELECT *
FROM rank_table
WHERE rankcolumn <= 5 

 /*6: From database, retrieve total SalesAmount in each month of internet_sales and reseller_sales. 
Gợi ý:  
Way 1: Tính doanh thu từng tháng (theo cột OrderDate) ở mỗi bảng độc lập FactInternetSales và FactResellerSales bằng sử dụng CTE 
Way 2: Dùng Subquery */ 

-- way 1: 
WITH inter_sale AS (
SELECT     
    YEAR(OrderDate) AS calendar_year
    , MONTH(OrderDate) AS calendar_month
    , SUM(SalesAmount) AS inter_sale_amount
FROM FactInternetSales
GROUP BY 
    YEAR(OrderDate)
    , MONTH(OrderDate)
)
, resell AS (
SELECT     
    YEAR(OrderDate) AS calendar_year
    , MONTH(OrderDate) AS calendar_month
    , SUM(SalesAmount) AS reseller_sale_amount
FROM FactResellerSales
GROUP BY 
    YEAR(OrderDate)
    , MONTH(OrderDate)
) 
SELECT inter.calendar_year
    , inter.calendar_month
    , inter_sale_amount
    , reseller_sale_amount
FROM inter_sale AS inter 
FULL JOIN resell
    ON inter.calendar_year = resell.calendar_year
    AND inter.calendar_month = resell.calendar_month
ORDER BY inter.calendar_year DESC
    , inter.calendar_month DESC

-- way 2: Subquery: 

SELECT 
    inter.calendar_year
    , inter.calendar_month
    ,inter_sale_amount
    , reseller_amount
FROM (
    SELECT Year(OrderDate) AS calendar_year, MONTH(OrderDate) as calendar_month
        , SUM(SalesAmount) AS inter_sale_amount
    FROM FactInternetSales
    GROUP BY Year(OrderDate), MONTH(OrderDate)
    ) AS inter 
FULL JOIN (
   SELECT Year(OrderDate) AS calendar_year, MONTH(OrderDate) as calendar_month
        , SUM(SalesAmount) AS reseller_amount
    FROM FactResellerSales
    GROUP BY Year(OrderDate), MONTH(OrderDate)
    ) AS resell 
ON inter.calendar_year = resell.calendar_year 
    AND inter.calendar_month = resell.calendar_month
ORDER BY inter.calendar_year DESC, inter.calendar_month DESC

/* 7 (hard): Từ kết quả bài tập 6, chỉ lấy kết quả của năm 2012 và 2013  
Tính tổng SalesAmount của cả 2 kênh Internet và Reseller theo tháng  
Giả sử KPI tổng SalesAmount của công ty trong năm 2012 là 30,000,000 và 2013 là 40,000,000. 
Tính xem năm 2012, 2013 công ty có đạt KPI hay không? Nếu đạt thì vào tháng mấy ở mỗi năm? */ 

WITH table_6 AS (
SELECT 
    inter.calendar_year
    , inter.calendar_month
    ,inter_sale_amount
    , reseller_amount
FROM (
    SELECT Year(OrderDate) AS calendar_year, MONTH(OrderDate) as calendar_month
        , SUM(SalesAmount) AS inter_sale_amount
    FROM FactInternetSales
    GROUP BY Year(OrderDate), MONTH(OrderDate)
    ) AS inter 
FULL JOIN (
   SELECT Year(OrderDate) AS calendar_year, MONTH(OrderDate) as calendar_month
        , SUM(SalesAmount) AS reseller_amount
    FROM FactResellerSales
    GROUP BY Year(OrderDate), MONTH(OrderDate)
    ) AS resell 
ON inter.calendar_year = resell.calendar_year 
    AND inter.calendar_month = resell.calendar_month
-- ORDER BY inter.calendar_year DESC, inter.calendar_month DESC
), 
running_table AS (
SELECT *
    , ISNULL(inter_sale_amount, 0) + ISNULL(reseller_amount, 0) AS total_amount_month
    , CASE WHEN calendar_year = 2012 THEN 30000000 
        WHEN calendar_year = 2013 THEN 40000000
        ELSE 0 END AS kpi
    , SUM( ISNULL(inter_sale_amount, 0) + ISNULL(reseller_amount, 0) ) OVER (PARTITION BY calendar_year ORDER BY calendar_month ) AS running_month
FROM table_6 
WHERE calendar_year IN (2012, 2013)
) 
SELECT *
    , running_month/kpi AS pct_kpi
FROM running_table
ORDER BY calendar_year , calendar_month 


-- Kiến thức thêm: PIVOT
-- PIVOT 
SELECT <non-pivoted column>,  
    [first pivoted column] AS <column name>,  
    [second pivoted column] AS <column name>,  
    ...  
    [last pivoted column] AS <column name>  
FROM  
    (<SELECT query that produces the data>)   
    AS <alias for the source query>  
PIVOT  
(  
    <aggregation function>(<column being aggregated>)  
FOR   
[<column that contains the values that will become column headers>]   
    IN ( [first pivoted column], [second pivoted column],  
    ... [last pivoted column])  
) AS <alias for the pivot table>  

-- example: 

SELECT TOP 5 * 
    --CustomerKey
FROM DimEmployee

-- output: DepartmentName, M, F

-- tạo rả bảng có thông tin số lượng nhân viên theo giới tính của từng Department

SELECT DepartmentName, Gender
    , COUNT(EmployeeKey) AS number_employee 
FROM DimEmployee
GROUP BY DepartmentName, Gender

WITH depart_table AS (
SELECT DepartmentName, Gender
    , COUNT(EmployeeKey) AS number_employee 
FROM DimEmployee
GROUP BY DepartmentName, Gender
) 
SELECT 
    DepartmentName
    , M
    , F
FROM depart_table
PIVOT (
    SUM(number_employee)
    FOR Gender IN ("M", "F")
) AS pivot_table

