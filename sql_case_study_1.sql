

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM sales

SELECT *
FROM menu

SELECT *
FROM members


-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id, 
	sum(price) As total_spending
FROM sales 
JOIN menu 
ON sales.product_id = menu .product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id, 
	count(order_date) AS visited_days
FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH rank_table AS (
SELECT
	S.customer_id, 
	M.product_name, 
	S.order_date,
	ROW_NUMBER() OVER (PARTITION BY S.Customer_ID ORDER BY S.order_date) AS rank
FROM Menu m
JOIN Sales s
ON m.product_id = s.product_id
GROUP BY S.customer_id, M.product_name,S.order_date
)
SELECT Customer_id, product_name
FROM rank_table
WHERE rank = 1

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	m.product_name, 
	COUNT(s.product_id) AS times_purchased
FROM sales s
INNER JOIN menu m
on s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY count(s.product_id) DESC;

--5. Which item was the most popular for each customer?

WITH rank_table AS (
	SELECT customer_id,
	product_id,
	count(product_id) as count, 
	row_number() OVER (partition by customer_id ORDER BY count(product_id) DESC) as ranking       
FROM sales 
GROUP BY customer_id, product_id
)
SELECT rank_table.customer_id, rank_table.product_id, m.product_name
FROM rank_table  
JOIN menu m
ON rank_table.product_id = m.product_id
WHERE rank_table.ranking = 1;

--6. Which item was purchased first by the customer after they became a member?

WITH Rank as (
	Select  S.customer_id,
	M.product_name,
	row_number() OVER (Partition by S.Customer_id Order by S.Order_date) as Rank
FROM Sales S
JOIN Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
WHERE S.order_date >= Mem.join_date  
)
SELECT *
FROM Rank
WHERE Rank = 1

--7. Which item was purchased just before the customer became a member?

With Rank as (
Select  S.customer_id,
        M.product_name,
	Dense_rank() OVER (Partition by S.Customer_id Order by S.Order_date) as Rank
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date  
)
Select customer_ID, Product_name
From Rank
Where Rank = 1


--8. What is the total items and amount spent for each member before they became a member?

Select 
	S.customer_id,
	count(S.product_id ) as quantity ,
	Sum(M.price) as total_sales
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date
Group by S.customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH Points AS
(
Select *, 
	CASE 
	WHEN product_id = 1 THEN price*20
	ELSE price*10
	END as Points
FROM Menu
)
SELECT S.customer_id, Sum(P.points) as Points
FROM Sales S
JOIN Points p
ON p.product_id = S.product_id
GROUP BY S.customer_id

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */

WITH dates AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM members 
)
SELECT S.Customer_id, 
       SUM(
	   Case 
	  When m.product_ID = 1 THEN m.price*20
	  When S.order_date between D.join_date and D.valid_date Then m.price*20
	  Else m.price*10
	  END 
	  ) AS Points
FROM Dates D
JOIN Sales S
ON D.customer_id = S.customer_id
JOIN Menu M
ON M.product_id = S.product_id
WHERE S.order_date < d.last_date
GROUP BY S.customer_id