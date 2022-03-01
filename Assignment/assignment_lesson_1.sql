-- CORRECT HOMEWORK LESSON 1
-- Task 1:

/* Create a list of all customer contact names that includes the title, first name, 
middle name (if any), last name, and suffix (if any) of all customers. */

SELECT -- HIển thị kết quả 
    Title 
    ,FirstName 
    ,MiddleName 
    ,LastName 
    ,Suffix 
FROM SalesLT.Customer


/* Retrieve customer names and phone numbers 
Each customer has an assigned salesperson. You must write a query to create a call sheet that lists: 
    - The salesperson 
    - A column named CustomerName that displays how the customer contact should be greeted (for example, Mr Smith) 
    - The customer’s phone number. */

-- way 2: 
SELECT
    Title
    , LastName
    , SalesPerson
    , Title + LastName AS CustomerName
    , CONCAT_WS(' ', Title, LastName, SalesPerson) AS CustomerName_1
    , CONCAT(Title, ' ', LastName, ' ' , SalesPerson) AS CustomerName_2
    , Phone
FROM SalesLT.Customer

-- CONCAT: Lệnh dùng để ghép các columns --> 
-- CONCAT_WS(special_letters, column1, column2, column3, ..)
--- Syntax:CONCAT(column1, column2, ...)

-- way 1: 

SELECT 
    SalesPerson
    ,Title
    ,LastName
    ,ISNULL(Title,'') + LastName AS CustomerName 
    ,Phone 
    ,Title + LastName AS new_name
FROM SalesLT.Customer


-- Task 2:

/* Retrieve a list of customer companies 
You have been asked to provide a list of all customer companies in the format 
Customer ID : Company Name - for example, 78: Preferred Bikes. */

SELECT * FROM SalesLT.Customer

SELECT
    CustomerID
    , Companyname
    , CAST(CustomerID AS varchar(100)) + ': ' + CompanyName AS FormatedName
    , CONCAT(CustomerID, ': ', CompanyName) AS FormatedName_1
FROM SalesLT.Customer

SELECT 
    CompanyName
    , CAST(CustomerID AS nvarchar(20))+ ': '+ CompanyName AS CustomerCompany 
FROM SalesLT.Customer

/* Retrieve a list of sales order revisions 
The SalesLT.SalesOrderHeader table contains records of sales orders. You have been asked to retrieve data for a report that shows: 
    - The sales order number and revision number in the format () – for example SO71774 (2). 
    - The order date converted to ANSI standard 102 format (yyyy.mm.dd – for example 2015.01.31). */

SELECT top 10 * FROM SalesLT.SalesOrderHeader

SELECT 
    SalesOrderNumber +' (' + CAST(revisionNumber AS nvarchar) + ')' AS SalesOrder 
   ,CONVERT(nvarchar,OrderDate, 102) AS OrderDate_ANSI
    FROM SalesLT.SalesOrderHeader

--Task 3: 
-- 3.1 
/* Retrieve customer contact names with middle names if known 
You have been asked to write a query that returns a list of customer names. 
The list must consist of a single column in the format first last (for example Keith Harris) if the middle name is unknown, 
or first middle last (for example Jane M. Gates) if a middle name is known.  */

SELECT TOP 10 
    FirstName
    , MiddleName
    , LastName
    , FirstName + ' ' +  ISNULL(MiddleName, '') + ' ' + LastName AS full_name
    , CONCAT_WS(' ', FirstName, MiddleName, LastName) AS full_name_1
    , CASE 
        WHEN MiddleName IS NULL THEN FirstName + ' ' + LastName 
        ELSE FirstName + ' ' +  MiddleName + ' ' + LastName
    END AS full_name_2
FROM SalesLT.Customer

-- LOGICAL STATEMENT: 
--- CASE WHEN : là mệnh đề giải quyết theo các điều kiện mình muốn, giống IF ELSE trong Excel 
---- Syntax: 
---- CASE 
---- WHEN condition_1 THEN value_1 
---- WHEN condition_2 THEN value_2
---- ...
---- ELSE value_N
---- END AS column_name

-- 3.2 
/* Retrieve primary contact details 
Customers may provide Adventure Works with an email address, a phone number, or both. 
If an email address is available, then it should be used as the primary contact method; 
if not, then the phone number should be used. You must write a query that returns a list of customer IDs in one column, 
and a second column named PrimaryContact that contains the email address if known, and otherwise the phone number. */

SELECT TOP 10 
    CustomerID 
    , EmailAddress
    , Phone            
    , ISNULL(EmailAddress, Phone) as new
    ,(CASE  
        WHEN EmailAddress IS NOT NULL THEN EmailAddress  
        ELSE Phone 
    END) AS PrimaryContact
    , COALESCE(EmailAddress, Phone) as new_2
FROM SalesLT.Customer 

--3.3 
/* Retrieve shipping status 
You have been asked to create a query that returns a list of sales order IDs 
and order dates with a column named ShippingStatus that contains the text Shipped for orders with a known ship date, 
and Awaiting Shipment for orders with no ship date. */

SELECT 
    SalesOrderID 
    , ShipDate
    ,(CASE  
        WHEN ShipDate IS NULL THEN 'Awaiting Shipment'  
        ELSE 'Shipped'
    END) AS ShippingStatus 
FROM SalesLT.SalesOrderHeader
