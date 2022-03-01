-- LESSON 2: 

---- SORTING: Sắp xếp dữ liệu
----- ORDER BY ASC/DESC 

SELECT 
    ProductCategoryID AS Category
    , [Name]
    , ListPrice
FROM SalesLT.Product
ORDER BY Category ASC, ListPrice DESC

-- LIMIT RESULT: Sẽ được thực hiện sau ORDER BY 
--- TOP N 

SELECT TOP 10
    ProductCategoryID AS Category
    , [Name]
    , ListPrice
FROM SalesLT.Product
ORDER BY Category ASC, ListPrice DESC

SELECT TOP 10 * FROM SalesLT.Product 

-- DISTINCT : Xử lý dũ liệu trùng lặp 

SELECT DISTINCT
    City
    , CountryRegion
FROM SalesLT.Address
ORDER BY CountryRegion, City;

-- rows: 450 
-- remove dup: 269 rows 

-- WHERE: Mệnh đề điều kiện

/* Example: Write a query using a WHERE clause that displays all the products listed in the SalesLT.Product table 
which have the color “black” and size is greater than 50. Display the ProductID, Name, Color, Size, for each one. */

SELECT 
  ProductID
  , Name
  , Color
  , Size
  , CASE 
    WHEN Size IS NULL THEN 0
    WHEN Size IN ('S', 'M', 'L', 'XL') THEN 0
    ELSE Size
    END AS new_size
FROM SalesLT.Product
WHERE Color = 'black'
    AND CASE 
        WHEN Size IS NULL THEN 0
        WHEN Size IN ('S', 'M', 'L', 'XL') THEN 0
        ELSE Size
        END > 50

/* ex2:
From table “SalesLT.Product” select all records that satisfy one of the following conditions:
Color belongs to “Red” or “Multi”
Size does NOT include the value NULL
SellStartDate in the period from ‘2005-01-01’ to ‘2007-07-01’
And must have Weight  > 10000 
*/ 

SELECT
    ProductID
    , Color
    , [Size]
    , SellStartDate
    , [Weight]
FROM SalesLT.Product
WHERE 
    Color IN ('Red', 'Multi')
    OR SIZE IS NOT NULL
    OR SellStartDate BETWEEN '2005-01-01' and '2007-07-01'
    OR [Weight] > 10000
ORDER BY SellStartDate DESC

-- BUILT-IN FUNCTION

SELECT DAY('2018/03/10') AS get_day

SELECT DATEPART(month, '2018/03/10') At

SELECT CURRENT_TIMESTAMP

SELECT DATEADD(day, 1, '2018-03-10') as date_add
SELECT DATEADD(month, 1, '2018-03-10') as date_add

SELECT DATEDIFF(year, '2017-03-10', '2018-03-10') as diff
SELECT DATEDIFF(month, '2017-03-10', '2018-03-10') as diff
SELECT DATEDIFF(day, '2017-03-10', '2018-03-10') as diff

-- CHARINDEX:Tìm vị trí của kí tự 
SELECT CHARINDEX('p', 'Datapot') AS char_index

--VD: 
SELECT
    ProductID
    , Color
    , [Size]
    , SellStartDate
    , [Weight]
    , CHARINDEX('a', Color) AS a_position
    , LEN(Color) AS len_color
FROM SalesLT.Product

SELECT LTRIM('     Datapot') AS Left_Trimmed
SELECT RTRIM('Datapot     ') AS Right_Trimmed
SELECT TRIM('       Datapot     ') AS Trimmed

SELECT REPLACE('Datapot', 'pot', 'top')

SELECT REPLICATE('Datapot ', 3)

SELECT REVERSE('Datapot')

SELECT SUBSTRING('Datapot', 1, 3) AS extract_string

SELECT STUFF('Datapot', 1, 4, 'Tea')    

/* 
Ex 2: From SalesOrderHeader table:
Calculate duration of each order when they are delivered to customers. (ShipDate - OrderDate)
Calculate duration of each order from DueDate to current time. (Today - DueDate)
*/ 

SELECT TOP 10 *
FROM SalesLT.SalesOrderHeader

SELECT 
    SalesOrderID
    , OrderDate
    , ShipDate
    , DueDate
    , CURRENT_TIMESTAMP AS today
    , DATEDIFF(day, OrderDate, ShipDate) AS delivery_time
    , DATEDIFF(day, DueDate, CURRENT_TIMESTAMP) AS duration_time
FROM SalesLT.SalesOrderHeader

/* 
Ex 3: Get name of each sale man. Name is last part of SalesPerson: adventure-works\jun0 -> Name = jun0 
*/ 
SELECT TOP 10 * FROM SalesLT.Customer


















