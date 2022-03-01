

-- LESSON 4: 

--- Aggregate Function: 
-- MIN(), MAX(), SUM(), COUNT(), AVG()

-- ex:
 
SELECT TOP 5 *
FROM 
    FactInternetSales

SELECT COUNT(*) AS nb_rows
    , MAX(UnitPrice) AS max_price
    , MIN(UnitPrice) AS min_price
    , SUM(UnitPrice) AS total_price
FROM FactInternetSales 

-- GROUP BY: Gom nhóm theo đối tượng 
-- Tính tổng số lượng đơn hàng theo ngày đặt hàng
-- Tính tổng số lượng khách hàng của mỗi ngày đặt hàng
-- Tổng số doanh thu (salesamount)

SELECT
    OrderDateKey -- group by cái gì select cái đó
    , COUNT(SalesOrderNumber) AS total_orders
    , COUNT(DISTINCT CustomerKey) AS total_customer
    , SUM(SalesAmount) AS total_revenue
FROM FactInternetSales
GROUP BY OrderDateKey
ORDER BY OrderDateKey

-- Quan sát theo tháng, năm 
SELECT
    LEFT(OrderDateKey,6) AS month_year -- group by cái gì select cái đó
    , COUNT(SalesOrderNumber) AS total_orders
    , COUNT(DISTINCT CustomerKey) AS total_customer
    , SUM(SalesAmount) AS total_revenue
FROM FactInternetSales
GROUP BY LEFT(OrderDateKey,6)
ORDER BY month_year

-- HAVING: Đặt điều kiện sau khi GROUP BY
SELECT
    LEFT(OrderDateKey,6) AS month_year -- group by cái gì select cái đó
    , COUNT(SalesOrderNumber) AS total_orders
    , COUNT(DISTINCT CustomerKey) AS total_customer
    , SUM(SalesAmount) AS total_revenue
FROM FactInternetSales
GROUP BY LEFT(OrderDateKey,6)
HAVING COUNT(SalesOrderNumber) > 3000 -- HAVING nó sẽ được execute sau GROUP BY (trước SELECT)
ORDER BY month_year

-- WHERE vs HAVING?
-- WHERE: đặt điều kiện đối với bảng dữ liệu chưa bị thay đổi cấu trúc 
-- HAVING: đặt điều kiện sau khi bảng dữ liệu đã thay đổi cấu trúc (sau group by)

-- CTE: Common Table Expression (Tạo bảng tạm bằng câu lệnh)

WITH temp_table AS (
    SELECT
    LEFT(OrderDateKey,6) AS month_year -- group by cái gì select cái đó
    , COUNT(SalesOrderNumber) AS total_orders
    , COUNT(DISTINCT CustomerKey) AS total_customer
    , SUM(SalesAmount) AS total_revenue
    FROM FactInternetSales
    GROUP BY LEFT(OrderDateKey,6)
    HAVING COUNT(SalesOrderNumber) > 3000
    -- ORDER BY month_year
)
SELECT * FROM temp_table

-- Muốn có 1 column (total_order_all_time)
-- WINDOWN FUNCTION 
-- Syntax: agg_function + OVER( PARITION BY column_name ORDER BY column_name )
-- 
WITH temp_table AS (
    SELECT
    LEFT(OrderDateKey,6) AS month_time
    , LEFT(OrderDateKey,4) AS year_time -- group by cái gì select cái đó
    , COUNT(SalesOrderNumber) AS total_orders
    , COUNT(DISTINCT CustomerKey) AS total_customer
    , SUM(SalesAmount) AS total_revenue
    FROM FactInternetSales
    GROUP BY  LEFT(OrderDateKey,6)
            , LEFT(OrderDateKey,4)
    -- HAVING COUNT(SalesOrderNumber) > 1000
    -- ORDER BY month_year
), -- liên kết các CTE bằng dấu phẩy 
temp_table_2 AS ( --CTE thứ 2 được phép dùng lại temp_table ở CTE 1
    SELECT * 
    , SUM(total_orders) OVER() AS total_order_all_time
    , SUM(total_orders) OVER( ORDER BY month_time ASC ) AS total_order_running -- cộng dồn tăng dần theo tháng
    , SUM(total_orders) OVER( PARTITION BY year_time) total_order_year -- tính tổng theo năm 
    , SUM(total_orders) OVER( PARTITION BY year_time ORDER BY month_time ASC) AS total_order_running_year
    FROM temp_table
)
SELECT * FROM temp_table_2 -- CTE phải đi kèm mệnh đề SELECT chính 

