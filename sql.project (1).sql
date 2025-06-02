USE ORDERS;

ALTER TABLE ADDRESS ADD PRIMARY KEY (ADDRESS_ID);

ALTER TABLE ONLINE_CUSTOMER ADD FOREIGN KEY (ADDRESS_ID) REFERENCES ADDRESS (ADDRESS_ID);

ALTER TABLE ORDER_HEADER ADD PRIMARY KEY (ORDER_ID);

ALTER TABLE ORDER_ITEMS ADD FOREIGN KEY (ORDER_ID) REFERENCES ORDER_HEADER (ORDER_ID);

ALTER TABLE PRODUCT_CLASS ADD PRIMARY KEY (PRODUCT_CLASS_CODE);
ALTER TABLE PRODUCT ADD FOREIGN KEY (PRODUCT_CLASS_CODE) REFERENCES PRODUCT_CLASS (PRODUCT_CLASS_CODE);

ALTER TABLE PRODUCT ADD PRIMARY KEY (PRODUCT_ID);
ALTER TABLE ORDER_ITEMS ADD FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT (PRODUCT_ID);

ALTER TABLE SHIPPER ADD PRIMARY KEY (SHIPPER_ID);
ALTER TABLE ORDER_HEADER ADD FOREIGN KEY (SHIPPER_ID) REFERENCES SHIPPER (SHIPPER_ID);

ALTER TABLE CARTON ADD PRIMARY KEY (CARTON_ID);

ALTER TABLE ONLINE_CUSTOMER ADD PRIMARY KEY (CUSTOMER_ID);
ALTER TABLE ORDER_HEADER ADD FOREIGN KEY (CUSTOMER_ID) REFERENCES ONLINE_CUSTOMER (CUSTOMER_ID);


-- PROBLEM 1
-- Write a query to display customer full name with their title (Mr/Ms), both first
-- name and last name are in upper case, customer email id, customer creation date
-- and display customer’s category after applying below categorization rules: i) IF
-- customer creation date Year <2005 Then Category A ii) IF customer creation date
-- Year >=2005 and <2011 Then Category B iii)IF customer creation date Year>= 2011
-- Then Category C Hint: Use CASE statement, no permanent change in table
-- required. [NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE]

-- SOLUTION
use orders;
show tables;
SELECT 
    -- Full name with assumed title and uppercase formatting
    CONCAT('Mr. ', UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS FULL_NAME,

    -- Customer email ID
    CUSTOMER_EMAIL,

    -- Customer creation date
    CUSTOMER_CREATION_DATE,

    -- Customer category based on creation year
    CASE 
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) >= 2005 AND EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        WHEN EXTRACT(YEAR FROM CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
    END AS CUSTOMER_CATEGORY

FROM ONLINE_CUSTOMER
LIMIT 500;

-- PROBLEM 2
-- Write a query to display the following information for the products, which have
-- not been sold: product_id, product_desc, product_quantity_avail, product_price,
-- inventory values (product_quantity_avail*product_price), New_Price after applying
-- discount as per below criteria. Sort the output with respect to decreasing value of
-- Inventory_Value. i) IF Product Price > 20,000 then apply 20% discount ii) IF Product
-- Price > 10,000 then apply 15% discount iii) IF Product Price =< 10,000 then apply
-- 10% discount # Hint: Use CASE statement, no permanent change in table required.
-- [NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]

-- SOLUTION
SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    P.PRODUCT_PRICE,
    (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
    CASE
        WHEN P.PRODUCT_PRICE > 20000 THEN P.PRODUCT_PRICE * 0.80
        WHEN P.PRODUCT_PRICE > 10000 THEN P.PRODUCT_PRICE * 0.85
        ELSE P.PRODUCT_PRICE * 0.90
    END AS NEW_PRICE
FROM 
    PRODUCT P
WHERE 
    P.PRODUCT_ID NOT IN (SELECT ORDER_ITEM.PRODUCT_ID FROM ORDER_ITEMS ORDER_ITEM)
ORDER BY 
    INVENTORY_VALUE DESC;
    
-- PROBLEM 3
-- Write a query to display Product_class_code, Product_class_description, Count of
-- Product type in each productclass, Inventory Value
-- (product_quantity_avail*product_price). Information should be displayed for only
-- those product_class_code which have more than 1,00,000. Inventory Value. Sort
-- the output with respect to decreasing value of Inventory_Value. [NOTE: TABLES to
-- be used - PRODUCT, PRODUCT_CLASS]

-- SOLUTION 3
SELECT 
    PC.PRODUCT_CLASS_CODE,
    'PC.PRODUCT_CLASS_DESCRIPTION',
    COUNT(P.PRODUCT_ID) AS PRODUCT_COUNT,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM 
    PRODUCT P
JOIN 
    PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
GROUP BY 
    PC.PRODUCT_CLASS_CODE, 'PC.PRODUCT_CLASS_DESCRIPTION'
HAVING 
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000
ORDER BY 
    INVENTORY_VALUE DESC;

-- PROBLEM 4
-- Write a query to display customer_id, full name, customer_email,
-- customer_phone and country of customers who have cancelled all the orders
-- placed by them (USE SUB-QUERY)[NOTE: TABLES to be used -
-- ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

-- SOLUTION 4
SELECT c.customer_id,
       CONCAT('c.first_name', ' ', 'c.last_name') AS full_name,
       c.customer_email,
       c.customer_phone,
       a.country
FROM ONLINE_CUSTOMER c
JOIN ADDRESS a ON c.address_id = a.address_id
WHERE c.customer_id NOT IN (
    SELECT oh.customer_id
    FROM ORDER_HEADER oh
    WHERE oh.order_status <> 'Cancelled'
    GROUP BY oh.customer_id
)
LIMIT 0, 100;


-- PROBLEM 5
-- Write a query to display Shipper name, City to which it is catering, number of
-- customers catered by the shipper in the city and number of consignments delivered
-- to that city for Shipper DHL [NOTE: TABLES to be used -
-- SHIPPER,ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

-- SOLUTION
SELECT 
    s.shipper_name, 
    a.city, 
    COUNT(DISTINCT c.customer_id) AS num_customers_catered, 
    COUNT(oh.order_id) AS num_consignments_delivered
FROM 
    SHIPPER s
JOIN 
    ORDER_HEADER oh ON s.shipper_id = oh.shipper_id
JOIN 
    ONLINE_CUSTOMER c ON oh.customer_id = c.customer_id
JOIN 
    ADDRESS a ON c.address_id = a.address_id
WHERE 
    s.shipper_name = 'DHL'
GROUP BY 
    s.shipper_name, a.city
LIMIT 0, 100;
/*
6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as below as per below condition: 
a. 	For Electronics and Computer categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
	if inventory quantity is less than 10% of quantity sold,show 'Low inventory, need to add inventory', if inventory quantity is less than 50% of quantity sold, 
	show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 
b.	For Mobiles and Watches categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
	if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', if inventory quantity is 
    less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 60% of quantity sold, 
    show 'Sufficient inventory' 
c. 	Rest of the categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 30% 
	of quantity sold, show 'Low inventory, need to add inventory', if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
    need to add some inventory', if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory' 
    -- (USE SUB-QUERY) -- [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
*/
-- SOLUTION_6a
SHOW DATABASES;
use orders;
DESCRIBE ORDERS;
DESCRIBE order_items;
DESCRIBE product_class;
show tables;
select * from product;
DESCRIBE PRODUCT;
SHOW COLUMNS FROM PRODUCT;
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD,
    pc.PRODUCT_CLASS_DESC,

    CASE 
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') AND COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN
            'No Sales in past, give discount to reduce inventory'
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') AND p.PRODUCT_QUANTITY_AVAIL < (0.10 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0)) THEN
            'Low inventory, need to add inventory'
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') AND p.PRODUCT_QUANTITY_AVAIL < (0.50 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0)) THEN
            'Medium inventory, need to add some inventory'
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') AND p.PRODUCT_QUANTITY_AVAIL >= (0.50 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0)) THEN
            'Sufficient inventory'
        ELSE
            'Not Applicable'
    END AS INVENTORY_STATUS

FROM product p
LEFT JOIN product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID

GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, pc.PRODUCT_CLASS_DESC

LIMIT 500;
-- SOLUTION 6b
 SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD,
    pc.PRODUCT_CLASS_DESC,
    
    CASE
        WHEN COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) = 0 THEN
            'No Sales in past, give discount to reduce inventory'
        WHEN p.PRODUCT_QUANTITY_AVAIL < 0.20 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN
            'Low inventory, need to add inventory'
        WHEN p.PRODUCT_QUANTITY_AVAIL < 0.60 * COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) THEN
            'Medium inventory, need to add some inventory'
        ELSE
            'Sufficient inventory'
    END AS INVENTORY_STATUS

FROM product p
JOIN product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID

WHERE pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches')

GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, pc.PRODUCT_CLASS_DESC

LIMIT 500;         
-- SOLUTION 6c
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    sales.QUANTITY_SOLD,
    pc.PRODUCT_CLASS_DESC,
    
    CASE
        WHEN sales.QUANTITY_SOLD = 0 THEN
            'No Sales in past, give discount to reduce inventory'
        WHEN p.PRODUCT_QUANTITY_AVAIL < 0.30 * sales.QUANTITY_SOLD THEN
            'Low inventory, need to add inventory'
        WHEN p.PRODUCT_QUANTITY_AVAIL < 0.70 * sales.QUANTITY_SOLD THEN
            'Medium inventory, need to add some inventory'
        ELSE
            'Sufficient inventory'
    END AS INVENTORY_STATUS

FROM product p
JOIN product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE

LEFT JOIN (
    SELECT PRODUCT_ID, COALESCE(SUM(PRODUCT_QUANTITY), 0) AS QUANTITY_SOLD
    FROM order_items
    GROUP BY PRODUCT_ID
) sales ON p.PRODUCT_ID = sales.PRODUCT_ID

WHERE pc.PRODUCT_CLASS_DESC NOT IN ('Mobiles', 'Watches')

LIMIT 500;

-- PROBLEM 7
-- Write a query to display order_id and volume of the biggest order (in terms of volume) 
-- that can fit in carton id 10 
-- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]

-- SOLUTION
SELECT * FROM carton LIMIT 10;
SELECT 
    oi.ORDER_ID,
    SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) AS ORDER_VOLUME
FROM ORDER_ITEMS oi
JOIN PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID
GROUP BY oi.ORDER_ID
HAVING ORDER_VOLUME <= (
    SELECT LEN * WIDTH * HEIGHT
    FROM CARTON
    WHERE CARTON_ID = 10
)
ORDER BY ORDER_VOLUME DESC
LIMIT 1;
/*
8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is 
Cash and customer last name starts with 'G' --[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/
SELECT 
    c.CUSTOMER_ID,
    CONCAT(UPPER(c.CUSTOMER_FNAME), ' ', UPPER(c.CUSTOMER_LNAME)) AS FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE
FROM ONLINE_CUSTOMER c
JOIN ORDER_HEADER oh ON c.CUSTOMER_ID = oh.CUSTOMER_ID
JOIN ORDER_ITEMS oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN PRODUCT p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE oh.PAYMENT_MODE = 'Cash'
  AND c.CUSTOMER_LNAME LIKE 'G%'
GROUP BY c.CUSTOMER_ID, FULL_NAME;
/*
9. Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201 and are 
not shipped to city Bangalore and New Delhi. Display the output in descending order with respect to the tot_qty. 
-- (USE SUB-QUERY) -- [NOTE: TABLES to be used - order_items, product,order_header, online_customer, address]
*/
-- SOLUTION
DESCRIBE order_header;
show columns from order_header;
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS tot_qty
FROM order_items oi
JOIN product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE oi.ORDER_ID IN (
    SELECT oh.ORDER_ID
    FROM order_header oh
    JOIN online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
    JOIN address a ON oc.ADDRESS_ID = a.ADDRESS_ID
    WHERE oh.ORDER_ID IN (
        SELECT ORDER_ID
        FROM order_items
        WHERE PRODUCT_ID = 201
    )
    AND a.CITY NOT IN ('Bangalore', 'New Delhi')
)
AND oi.PRODUCT_ID <> 201
GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY tot_qty DESC;
/*
10. Write a query to display the order_id,customer_id and customer fullname, total quantity of products shipped for order ids which are 
even and shipped to address where pincode is not starting with "5" 
-- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address]
*/SELECT 
    oh.ORDER_ID,
    oh.CUSTOMER_ID,
    CONCAT(UPPER(oc.CUSTOMER_FNAME), ' ', UPPER(oc.CUSTOMER_LNAME)) AS CUSTOMER_FULLNAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM order_header oh
JOIN online_customer oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN address a ON oc.ADDRESS_ID = a.ADDRESS_ID
JOIN order_items oi ON oh.ORDER_ID = oi.ORDER_ID
WHERE MOD(oh.ORDER_ID, 2) = 0  -- even order IDs
AND a.PINCODE NOT LIKE '5%'    -- pincode not starting with 5
GROUP BY oh.ORDER_ID, oh.CUSTOMER_ID, CUSTOMER_FULLNAME;


