-- CORRECT HOMEWORK LESSON 5 --


/* 1: Từ bảng DimProduct, DimSalesTerritory và FactInternetSales, hãy truy vấn ra các thông tin sau của các đơn hàng được đặt trong năm 2013 và 2014: */

-- 
SELECT 
    SalesOrderNumber 
    , SalesOrderLineNumber 
    , inter.ProductKey 
    , EnglishProductName 
    , SalesTerritoryCountry 
    , SalesAmount 
    , OrderQuantity 
FROM FactInternetSales AS inter  
LEFT JOIN DimProduct AS pro  
    ON inter.ProductKey = pro.ProductKey 
LEFT JOIN DimSalesTerritory AS terri  
    ON inter.SalesTerritoryKey = terri.SalesTerritoryKey 
WHERE YEAR(OrderDate) IN (2013,2014) -- LEFT  (OrderDateKey,4) 
-- OrderDateKey: 

-- 54,771 rows

/* 2: Từ bảng DimProduct, DimSalesTerritory và FactInternetSales, tính tổng doanh thu (đặt tên là InternetTotalSales)
và số đơn hàng (đặt tên là NumberofOrders) của từng sản phẩm theo mỗi quốc gia từ bảng DimSalesTerritory. Kết quả trả về gồm có các thông tin sau:

SalesTerritoryCountry : DimSalesTerritory
ProductKey : DimProduct
EnglishProductName: DimProduct
InternetTotalSales : SUM(SalesAmount)
NumberofOrders: COUNT(SalesOrderNumber) 

--> Tính theo sản phẩm: GROUP BY ProductKey

 */

-- way 1:
SELECT SalesTerritoryCountry
     , DP.ProductKey
     , EnglishProductName
     , SUM(SalesAmount)                 AS InternetTotalSales
     , COUNT(DISTINCT SalesOrderNumber) AS NumberofOrders
FROM FactInternetSales AS FS
         LEFT JOIN DimProduct AS DP
                   ON DP.ProductKey = FS.ProductKey
         LEFT JOIN DimSalesTerritory DST
                   ON DST.SalesTerritoryKey = FS.SalesTerritoryKey
GROUP BY SalesTerritoryCountry
       , DP.ProductKey -- mã sản phẩm 
       , EnglishProductName -- tên sản phẩm 


-- way 2:
SELECT DISTINCT 
SalesTerritoryCountry 
, inte.ProductKey 
, EnglishProductName 
, Sum(SalesAmount) OVER (PARTITION by SalesTerritoryCountry, inte.ProductKey) as InternetTotalSales 
, Sum(OrderQuantity) OVER (PARTITION BY SalesTerritoryCountry, inte.ProductKey) as NumberofOrders 
FROM FactInternetSales AS inte 
LEFT JOIN DimProduct AS pro  
    ON inte.ProductKey = pro.ProductKey 
LEFT JOIN DimSalesTerritory AS terri  
    ON inte.SalesTerritoryKey = terri.SalesTerritoryKey 

/* 3: Từ bảng DimProduct, DimSalesTerritory và FactInternetSales,
hãy tính toán % tỷ trọng doanh thu của từng sản phẩm (đặt tên là PercentofTotaInCountry)
trong Tổng doanh thu của mỗi quốc gia. Kết quả trả về gồm có các thông tin sau:
SalesTerritoryCountry
ProductKey
EnglishProductName
InternetTotalSales
PercentofTotaInCountry (định dạng %)
*/
-- way 1
WITH amount_product AS (
SELECT SalesTerritoryCountry
     , DP.ProductKey
     , EnglishProductName
     , SUM(SalesAmount)                 AS InternetTotalSales
     , COUNT(DISTINCT SalesOrderNumber) AS NumberofOrders
FROM FactInternetSales AS FS
         LEFT JOIN DimProduct AS DP
                   ON DP.ProductKey = FS.ProductKey
         LEFT JOIN DimSalesTerritory DST
                   ON DST.SalesTerritoryKey = FS.SalesTerritoryKey
GROUP BY SalesTerritoryCountry
       , DP.ProductKey -- mã sản phẩm 
       , EnglishProductName -- tên sản phẩm 
)
SELECT *
    , SUM(InternetTotalSales) OVER (PARTITION BY SalesTerritoryCountry) AS InternetTotalSalesCountry
    , FORMAT(InternetTotalSales/SUM(InternetTotalSales) OVER (PARTITION BY SalesTerritoryCountry), 'p') AS PercentofTotaInCountry
FROM amount_product

-- way 2
WITH TotalSalesbyProduct AS (
    SELECT SalesTerritoryCountry
         , DP.ProductKey
         , EnglishProductName
         , SUM(SalesAmount) AS InternetTotalSales
    FROM FactInternetSales FS
             LEFT JOIN DimProduct AS DP
                       ON DP.ProductKey = FS.ProductKey
             LEFT JOIN DimSalesTerritory DST
                       ON DST.SalesTerritoryKey = FS.SalesTerritoryKey
    GROUP BY SalesTerritoryCountry
           , DP.ProductKey
           , EnglishProductName
)
   , TotalSalesbyCountry AS (
    SELECT SalesTerritoryCountry
         , SUM(SalesAmount) AS TotalCountrySales
    FROM FactInternetSales FS
             LEFT JOIN DimProduct AS DP
                       ON DP.ProductKey = FS.ProductKey
             LEFT JOIN DimSalesTerritory DST
                       ON DST.SalesTerritoryKey = FS.SalesTerritoryKey
    GROUP BY SalesTerritoryCountry
)
SELECT SP.SalesTerritoryCountry
     , ProductKey
     , EnglishProductName
     , InternetTotalSales
     , TotalCountrySales
     , FORMAT(InternetTotalSales / TotalCountrySales, 'P') AS PercentofTotalInCountry
FROM TotalSalesbyProduct SP
         LEFT JOIN TotalSalesbyCountry SC
                   ON SP.SalesTerritoryCountry = sc.SalesTerritoryCountry
ORDER BY SalesTerritoryCountry, ProductKey;

-- way 3 
WITH tempt as( 
    SELECT DISTINCT 
        SalesTerritoryCountry 
        , inte.ProductKey 
        , EnglishProductName 
        , Sum(SalesAmount) OVER (PARTITION by SalesTerritoryCountry, inte.ProductKey) as InternetTotalSales 
        , Sum(SalesAmount) OVER (PARTITION by SalesTerritoryCountry) as CountryTotalSales 
    FROM FactInternetSales AS inte 
    LEFT JOIN DimProduct AS pro  
        ON inte.ProductKey = pro.ProductKey 
    LEFT JOIN DimSalesTerritory AS terri  
        ON inte.SalesTerritoryKey = terri.SalesTerritoryKey 
) 
SELECT * 
    , 100*InternetTotalSales/CountryTotalSales  as PercentofTotaInCountry 
FROM tempt 
ORDER BY SalesTerritoryCountry, PercentofTotaInCountry DESC

/* 4: Từ bảng FactInternetSales, và DimCustomer,
hãy truy vấn ra danh sách top 3 khách hàng có tổng doanh thu tháng (đặt tên là CustomerMonthAmount) cao nhất trong hệ thống theo mỗi tháng.
Kết quả trả về gồm có các thông tin sau:
OrderYear
OrderMonth
CustomerKey
CustomerFullName (kết hợp từ FirstName, MiddleName, LastName)
CustomerMonthAmount
*/

--key: 
WITH CustomerbyMonth AS (
    SELECT YEAR(OrderDate) AS OrderYear
         , MONTH(OrderDate) AS OrderMonth
         , DC.CustomerKey
         , CONCAT_WS(' ', FirstName, MiddleName, LastName) AS CustomerFullname
         , SUM(SalesAmount) AS CustomerMonthAmount
         , ROW_NUMBER() OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate) ORDER BY SUM(SalesAmount) DESC) AS CustomerRank
    FROM FactInternetSales AS FS
             LEFT JOIN DimCustomer DC
                       ON FS.CustomerKey = DC.CustomerKey
    GROUP BY DC.CustomerKey
           , CONCAT_WS(' ', FirstName, MiddleName, LastName)
           , YEAR(OrderDate)
           , MONTH(OrderDate)
)
SELECT OrderYear
     , OrderMonth
     , CustomerKey
     , CustomerFullname
     , CustomerMonthAmount
     , CustomerRank
FROM CustomerbyMonth
WHERE CustomerRank <= 3
ORDER BY OrderYear, OrderMonth, CustomerKey

/* 5: Từ bảng FactInternetSales,
tính toán tổng doanh thu theo từng tháng (đặt tên là InternetMonthAmount). Kết quả trả về gồm có các thông tin sau:
OrderYear
OrderMonth
InternetMonthAmount
*/
-- way 1
SELECT YEAR(OrderDate)  AS OrderYear
     , MONTH(OrderDate) AS OrderMonth
     , SUM(SalesAmount) AS InternetMonthAmount
FROM FactInternetSales
GROUP BY YEAR(OrderDate)
       , MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- way 2
SELECT DISTINCT 
    Year(OrderDate) as OrderYear 
    , Month(OrderDate) as OrderMonth 
    , SUM(SalesAmount) OVER(PARTITION BY Year(OrderDate), Month(OrderDate)) as InternetMonthAmount 
FROM FactInternetSales 
ORDER BY OrderYear asc, OrderMonth asc 

/* 6 (hard). Từ bảng FactInternetSales hãy tính toán % tăng trưởng doanh thu (đặt tên là PercentSalesGrowth) so với cùng kỳ năm trước (ví dụ: 
Tháng 11 năm 2012 thì so sánh với tháng 11 năm 2011). */

-- way 1:
WITH current_year_table as( 
    SELECT
        Year(OrderDate) as OrderYear 
        , Month(OrderDate) as OrderMonth 
        , SUM(SalesAmount) as InternetMonthAmount
    FROM FactInternetSales
    GROUP BY Year(OrderDate), Month(OrderDate)
), 
last_year_table as( 
    SELECT  
     Year(Dateadd(year,1,OrderDate)) as compare_year 
     , Month(OrderDate) as compare_month 
     , SUM(SalesAmount) as InternetMonthAmountLast
    FROM FactInternetSales
    GROUP BY Year(Dateadd(year,1,OrderDate)), Month(OrderDate)
) 
SELECT DISTINCT 
    OrderYear 
    , OrderMonth 
    , InternetMonthAmount 
    , InternetMonthAmountLast 
    , FORMAT((InternetMonthAmount-InternetMonthAmountLast)/InternetMonthAmountLast, 'p') as PercentSalesGrowth 
FROM current_year_table AS cur 
LEFT JOIN last_year_table AS las 
    ON OrderYear = compare_year  AND OrderMonth = compare_month
ORDER BY OrderYear asc, OrderMonth asc 

-- way 2:
WITH temp1 as( 
    SELECT DISTINCT 
        Year(OrderDate) as OrderYear 
        , Month(OrderDate) as OrderMonth 
        -- , OrderDate 
        , SUM(SalesAmount) OVER(PARTITION BY Year(OrderDate), Month(OrderDate)) as InternetMonthAmount
FROM FactInternetSales 
), 
temp2 as( 
    SELECT DISTINCT 
     Year(Dateadd(year,1,OrderDate)) as last_year 
     , Month(Dateadd(year,1,OrderDate)) as last_month 
    --  , Dateadd(year,-1,OrderDate) as cr_orderdate 
     , SUM(SalesAmount) OVER(PARTITION BY Year(Dateadd(year,1,OrderDate)), Month(Dateadd(year,1,OrderDate))) as InternetMonthAmountLast
    FROM FactInternetSales
) 
SELECT DISTINCT 
    OrderYear 
    , OrderMonth 
    , InternetMonthAmount 
    , InternetMonthAmountLast 
    , 100*(InternetMonthAmount-InternetMonthAmountLast)/InternetMonthAmountLast as PercentSalesGrowth 
FROM temp1 
LEFT JOIN temp2 
    ON OrderYear = last_year  AND OrderMonth = last_month
ORDER BY OrderYear asc, OrderMonth asc 

-- way 4: 

WITH table1 AS (
SELECT 
    YEAR (OrderDate) AS OrderYear
    , MONTH (OrderDate) AS OrderMonth
    , SUM(SalesAmount) InternetMonthAmount
    , LAG(SUM(SalesAmount), 12) OVER (ORDER BY YEAR (OrderDate), MONTH (OrderDate)) AS LastYearInternetAmount
FROM 
    FactInternetSales
GROUP BY 
    YEAR (OrderDate) 
    , MONTH (OrderDate) 
)
SELECT *
    , (InternetMonthAmount - LastYearInternetAmount)/ LastYearInternetAmount AS PercentSalesGrowth
FROM 
    table1
ORDER BY OrderYear, OrderMonth 

/* 7. Case study: Retention  

7.1 Từ bảng FactInternetSales , hãy tính xem mỗi khách hàng mua bao nhiêu đơn hàng? 
Nếu một khách hàng mua > 1 đơn hàng thì được xếp vào nhóm Returning user, 
hãy tính tỉ lệ Retention rate = Total of returning users/ Total users */ 

-- way 1: 
SELECT * 
    , 100*COUNT(returning_user) OVER()/total_users as retention_rate 
FROM (
    SELECT DISTINCT 
        CustomerKey 
        , COUNT(SalesOrderNumber) as customer_order 
        , COUNT(Customerkey) OVER() as total_users 
        , CASE  
            WHEN COUNT(SalesOrderNumber) >1 THEN 'Returning User' 
          END as returning_user 
      FROM FactInternetSales 
GROUP BY CustomerKey
) as tempt

-- way 2: 
WITH count_cust AS (
SELECT DISTINCT 
        CustomerKey 
        , COUNT(SalesOrderNumber) as customer_order 
        , COUNT(Customerkey) OVER() as total_users 
        , CASE  
            WHEN COUNT(SalesOrderNumber)>1 THEN 'Returning User' 
            ELSE 'no return'
          END as group_user  
      FROM FactInternetSales 
GROUP BY CustomerKey
) 
SELECT group_user
    , COUNT(CustomerKey) AS nb_user
    , SUM(COUNT(CustomerKey)) OVER() AS total_users
    , COUNT(CustomerKey)/ SUM(COUNT(CustomerKey)) OVER() AS pct
FROM count_cust
GROUP BY group_user