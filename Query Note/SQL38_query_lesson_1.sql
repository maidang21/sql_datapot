
-- Khai báo để viết note
/* 
Cách viết note khi có nhiều dòng
...
*/ 

-- SELECT: Hiển thị kết quả
--- SELECT *: Hiển thị tất cả dữ liệu trong bảng
SELECT *
FROM SalesLT.Product

--- SELECT ColumnName1, columnName2, ... : Hiển thị từng cột dữ liệu mình muốn
SELECT
    ProductID
    , Name
    , Color 
    , Size
FROM SalesLT.Product -- lấy data từ bảng product

--- ALIAS: đặt biệt danh cho column hoặc table 
---- camel: ProductNumber
---- snake: product_name
SELECT
    ProductID
    , Name AS product_name
    , Color 
    , Size
    , 'company_a' AS company_name
    , ListPrice
    , ListPrice * 1000 AS new_list_price -- (-), (+), (%)
FROM SalesLT.Product 

-- DÙNG PHÉP + ĐỂ GHÉP CÁC CHUỖI , CỘNG CÁC SỐ
SELECT 
    CustomerID
    , Title
    , FirstName
    , MiddleName
    , LastName
    , FirstName + MiddleName + LastName AS full_name
    -- , CustomerID + FirstName AS cus -- int + nvarchar (wrong) -- Phải cùng data type thì mới + được 
FROM SalesLT.Customer

-- NULL: Dữ liệu bị rỗng, unknown
SELECT 
    CustomerID
    , Title
    , FirstName
    , MiddleName
    , LastName
    , ISNULL(MiddleName, 'unknown') AS modified_middle_name
    -- , NULLIF(LastName, 'Harris') AS modified_last_name -- ít sử dụng 
    , COALESCE(MiddleName, FirstName, LastName ) AS column_new
FROM SalesLT.Customer

-- CAST: Chuyển đổi kiểu dữ liệu CAST(column AS new_data_type)
SELECT
    ProductID
    , Name
    , Color 
    , Size
    , ListPrice
    , CAST(ListPrice AS INT) AS price_int
    -- , CAST(Size AS int) AS new_size
    , TRY_CAST(Size AS int) AS new_size
FROM SalesLT.Product 

-- CONVERT: Chuyển đổi kiểu dữ liệu 
--- syntax: CONVERT ('new_data_type', column_name, [style])
SELECT
    ProductID
    , Name
    , Color 
    , Size
    , ListPrice
    , SellStartDate
    , CAST(ListPrice AS INT) AS price_int
    , CONVERT(INT, ListPrice) AS convert_price
    , CONVERT(nvarchar, SellStartDate) AS new_date
    , CONVERT(nvarchar, SellStartDate, 101) AS new_date_style
FROM SalesLT.Product      