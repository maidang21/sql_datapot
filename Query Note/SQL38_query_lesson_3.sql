-- LESSON 3: 

-- I. Subquery: Mềnh đề truy vấn lồng ghép
-- Các vị trí của Subquery: SELECT, FROM, WHERE

-- WHERE: 
SELECT 
    ProductID
    , ProductNumber
    , Name
    , ListPrice 
FROM SalesLT.Product 
WHERE (Name LIKE '%HL %' OR Name LIKE '%Mountain%')
    AND LEN(ProductNumber) >= 8 
    AND ProductID NOT IN (SELECT 
                            DISTINCT ProductID 
                            FROM SalesLT.SalesOrderDetail)

-- Nằm trong SELECT: 
SELECT 
    ProductID
    , ProductNumber
    , Name
    , ListPrice
    , (SELECT DISTINCT MAX(ProductID) FROM SalesLT.SalesOrderDetail) AS max_product_id
FROM SalesLT.Product 

-- Nằm trong FROM: Lưu ý cần có Alias nếu Subquery ở FROM

SELECT ProductID
FROM ( SELECT ProductID, OrderQty
        FROM SalesLT.SalesOrderDetail
        WHERE ProductID > 800 ) AS tmp_table

-- JOIN: Ghép nối các bảng dữ liệu, mở rộng data theo chiều ngang
-- INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN
-- Syntax: 
SELECT ...
FROM Table1 
JOIN Table2
    ON <predicate> -- key_join 


-- SalesLT.ProductCategory: PK là ProductCategoryID
-- SalesLT.Product: PK là ProductID và FK là ProductCategoryID
--> Key_join: ProductCategoryID

SELECT TOP 5 * FROM SalesLT.ProductCategory
SELECT TOP 5 * FROM SalesLT.Product

-- INNER JOIN 
SELECT cat.ProductCategoryID
    , [Size]
    , ProductNumber
FROM SalesLT.ProductCategory AS cat
INNER JOIN SalesLT.Product AS pro 
    ON cat.ProductCategoryID = pro.ProductCategoryID

-- rows: 295 --> Có 295 dòng dữ liệu trùng khớp giữa 2 bảng 

-- LEFT JOIN 
SELECT cat.ProductCategoryID
    , [Size]
    , ProductNumber
FROM SalesLT.ProductCategory AS cat
LEFT JOIN SalesLT.Product AS pro 
    ON cat.ProductCategoryID = pro.ProductCategoryID

-- rows: 299 --> chính là số rows của bảng SalesLT.ProductCategory

-- RIGHT JOIN 
SELECT cat.ProductCategoryID
    , [Size]
    , ProductNumber
FROM SalesLT.ProductCategory AS cat
RIGHT JOIN SalesLT.Product AS pro 
    ON cat.ProductCategoryID = pro.ProductCategoryID

-- rows: 295 --> chính là số dòng dữ liệu của bảng pro. Và tất cả dữ liệu của bảng pro đều có trong bảng cat

-- FULL OUTER JOIN 
SELECT cat.ProductCategoryID
    , [Size]
    , ProductNumber
FROM SalesLT.ProductCategory AS cat
FULL JOIN SalesLT.Product AS pro 
    ON cat.ProductCategoryID = pro.ProductCategoryID

-- rows: 299 

/* Exercise 1: Write a query using SalesLT.ProductCategory and SalesLT.Product,
display ProductID, ProductName, Color and ProductCategoryID of product
which ProductCategoryName contains 'Mountain' */

SELECT cat.ProductCategoryID -- Nếu column_name tồn tại giống nhau ở 2 tables thì khi SELECT nhớ khai báo tiền tố (table)
    , ProductID
    , pro.Name AS ProductName
    , cat.Name AS ProductCategoryName
    , Color
FROM SalesLT.ProductCategory AS cat
FULL JOIN SalesLT.Product AS pro 
    ON cat.ProductCategoryID = pro.ProductCategoryID
WHERE cat.Name LIKE '%Mountain%'

-- result: 60 rows

SELECT TOP 5 * FROM SalesLT.ProductCategory

/* Exercise 2: Write a query using SalesLT.SalesOrderHeader, SalesLT.Product and
SalesLT.SalesOrderDetail display SalesOrderID, SalesOrderDetailID, ProductID,
ProductName, OrderDate, LineTotal, SubTotal */

SELECT TOP 5 * FROM SalesLT.SalesOrderHeader
SELECT TOP 5 * FROM SalesLT.SalesOrderDetail
SELECT TOP 5 * FROM SalesLT.Product

-- JOIN WITH MUTIL TABLES
SELECT 
    detail.SalesOrderID -- trong bảng SalesOrderHeader
    , SalesOrderDetailID -- SalesOrderDetail
    , detail.ProductID 
    , Name AS ProductName -- bảng product
    , LineTotal
    , SubTotal
FROM SalesLT.SalesOrderDetail AS detail 
FULL JOIN SalesLT.SalesOrderHeader AS header 
    ON detail.SalesOrderID = header.SalesOrderID
FULL JOIN SalesLT.Product AS pro
    ON detail.ProductID = pro.ProductID

-- result left join: 542 rows 
-- result full join: 695 rows 

-- Kiểm tra số row number trong mỗi bảng
SELECT COUNT(*) FROM FactInternetSales -- rows: 
SELECT COUNT(*) FROM FactResellerSales -- rows: 

-- UNION: GHÉP BẢNG THEO CHIỀU DỌC và Có loại bỏ trùng lặp 
SELECT ProductKey
    , OrderDateKey
    , DueDateKey
FROM FactInternetSales
UNION 
SELECT ProductKey
    , OrderDateKey
    , DueDateKey 
FROM FactResellerSales
-- rows:26,819

-- UNION ALL: GHÉP BẢNG THEO CHIỀU DỌC và giữ hết tất cả dòng dữ liệu của 2 bảng

SELECT ProductKey
    , OrderDateKey
    , DueDateKey
FROM FactInternetSales
UNION ALL
SELECT ProductKey
    , OrderDateKey
    , DueDateKey 
FROM FactResellerSales
-- rows: 121,253





