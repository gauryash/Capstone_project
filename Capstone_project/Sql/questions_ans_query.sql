use supply_chain;

-- 1.	Read the data from all tables.
describe supply_chain;

# -- 2.	Find the country wise count of customers.
select country,count(*) as country_count from customer
group by country
order by country_count desc;

# -- 3.	Display the products which are not discontinued.
select * from product
where isDiscontinued=0;

# -- 4.	Display the list of companies along with the product name that they are supplying.
select Companyname,group_concat(productname) ,count(productname) from supplier
join product on supplier.id=product.supplierid
group by companyname;

# -- 5.	Display customer's information who stays in 'Mexico'
select * from customer
where country="Mexico";

# -- 6.	Display the price of costliest item that is ordered by the customer along with the customer details.
select c.firstname,c.lastname,o.id,o.ordernumber,o.totalamount,oi.productid,oi.unitprice 
from orders as o
join customer as c on o.customerid=c.id
join orderitem as oi on o.id=oi.orderid
group by oi.id
having oi.unitprice=(select max(unitprice) from orderitems);


# -- 7.	Display supplier id who owns highest number of products.

select supplier.id,supplier.companyname,count(product.productname) as countprod from supplier
join product on supplier.id=product.supplierid
group by supplier.id
order by countprod desc;

# -- 8.	Display month wise and year wise count of the orders placed.

with q1 as (select *,date_format(orderdate,"%M") as monthwise,date_format(orderdate,"%Y") as yearwise from orders)
select q1.monthwise,count(ordernumber) from q1
group by q1.monthwise;

with q1 as (select *,date_format(orderdate,"%M") as monthwise,date_format(orderdate,"%Y") as yearwise from orders)
select q1.yearwise,count(q1.ordernumber) from q1
group by q1.yearwise;

with q1 as (select *,date_format(orderdate,"%M") as monthwise,date_format(orderdate,"%Y") as yearwise from orders)
select monthwise,yearwise,count(q1.ordernumber) from q1
group by monthwise,yearwise;

# -- 9.	Which country has maximum suppliers.
select Country,count(companyname) as count_comp from supplier
group by country
order by count_comp desc
limit 1;

# -- 10. Which customers did not place any order.

select id,Firstname,lastname from customer
where id not in (select customerid from orders);

select * from customer 
left join orders on customer.id=orders.customerid
where orders.ordernumber is null; 

# part-B
# -- 1.	Arrange the product id, product name based on high demand by the customer.

select count(p.id) as count_prod ,group_concat(distinct p.productname),oi.orderid from product as p
join orderitem  as oi on p.id=oi.productid
join orders as o on oi.orderid=o.id
group by p.id
order by count_prod desc;

select p.id,p.productname,count(oi.orderid) as freq_order from product as p
join orderitem as oi on p.id=oi.productid
group by p.id
order by freq_order desc;

# -- 2.	Display the number of orders delivered every year.
select date_format(orderdate,"%Y") as yearwise , count(ordernumber) from orders
group by yearwise;

# -- 3.	Calculate year-wise total revenue.

select date_format(orderdate,"%Y") as yearwise , sum(totalamount) from orders
group by yearwise;

# -- 4.	Display the customer details whose order amount is maximum including his past orders.

with q1 as (select c.id as cust_id ,c.firstname,o.id as ord_id ,o.ordernumber,o.orderdate,o.totalamount,dense_rank()
over( partition by c.id order by o.orderdate desc) as as_rank from customer as c
join orders as o on c.id=o.customerid)

select * from q1
where as_rank in (1,2) ;

# -- 5.	Display total amount ordered by each customer from high to low. (donot use sum)

select * from customer as c
join orders as o on c.id=o.customerid
group by c.id
order by o.totalamount desc;

# /* A sales and marketing department of this company wants to find out how frequently 
#customer have business with them. This can be done in two ways. (Answer Q 6 and Q 7 for the same) */
# -- 6 Approach 1. List the current and previous order amount for each customers.

with q1 as (select c.id as cust_id ,c.firstname,o.id as ord_id ,o.ordernumber,o.orderdate,o.totalamount,dense_rank()
over( partition by c.id order by o.orderdate desc) as as_rank from customer as c
join orders as o on c.id=o.customerid)

select * from q1
where as_rank in (1,2);

select c.id,o.totalamount,lag(o.totalamount)over (partition by c.id) from customer as c
join orders as o on c.id=o.customerid
;

# /* 7. Approach 2. Display the customerid, order ids and the 
#order dates along with the previous order date and the next order date for every customer in the table:: */


# 
-- 8.	Find out top 3 suppliers in terms of revenue generated by their products.

select s.id as supplier_id,s.companyname,p.id as product_id ,p.productname,p.unitprice,o.customerid,sum(o.totalamount) as revenue
from supplier as s
join product as p on s.id=p.supplierid
join orderitem as oi on p.id=oi.productid
join orders as o on oi.orderid=o.id
group by supplier_id #,product_id 
order by revenue desc; 

SELECT SupplierId, ContactName, CompanyName, SUM(TotalAmount) REVENUE 
FROM supplier T1 JOIN product T2 ON T1.Id = T2.SupplierId 
JOIN orderitem T3 ON T3.ProductId = T2.Id
JOIN orders T4 ON T4.Id = T3.OrderId 
GROUP BY SupplierId, ContactName 
ORDER BY SUM(TotalAmount) DESC 
LIMIT 3;


### PART C::: 

-- 1.	Fetch the records to display the customer details who ordered more than 10 products in the single order

select c.id,c.firstname,c.lastname,o.id as orderid,o.ordernumber,o.customerid,oi.id as orderitem_id,count(oi.productid)as count_prod 
from orders as o
join orderitem as oi on  o.id=oi.orderid
join customer as c on o.customerid=c.id
group by orderid
having count_prod >=10;

# -- 2.	Display all the product details with the ordered quantity size as 1.

select p.id as productid,p.productname,oi.id as orderitem_id,oi.orderid,oi.quantity,o.ordernumber from product as p
join orderitem as oi on p.id=oi.productid
join orders as o on oi.orderid=o.id
#group by ordernumber
having quantity =1;

# -- 3.	Display the compan(y)ies which supplies products whose cost is above 100.

select s.id , s.companyname,p.unitprice from supplier as s
join product as p on s.id=p.supplierid
where unitprice>=100;

# -- 4.	Create a combined list to display customers and supplier list as per the below format.
select distinct(group_concat(companyname)) from supplier;
select * from supplier;

# -- 5.	Display the customer list who belongs to same city and country arrange in country wise.

select group_concat(firstname) as customer_list,city,country from customer
group by city,country
order by country;

# 

### PART D:::
-- 1.	Company sells the product at different discounted rates. Refer actual product price in product table and 
#selling price in the order item table.
-- Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 

with q1 as (select p.id as product_id,oi.orderid,p.unitprice as actual_price,oi.unitprice as selling_price,oi.quantity 
from product as p
join orderitem as oi on p.id=oi.productid)

select *,sum((q1.actual_price*q1.quantity)-(q1.selling_price*q1.quantity)) as total_amount_saved from q1
group by orderid;

# -- 2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.
select * from supplier
where companyname like "%richard%";

select * from customer;

# -- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- •	Both customer and supplier belong to the same country
-- •	Customer who does not have supplier in their country
-- •	Supplier who does not have customer in their country

select c.country,group_concat(distinct firstname),group_concat(distinct companyname) from customer as c
join supplier as s on c.country=s.country
group by c.country;

select c.country as cust_country,group_concat(distinct c.firstname) as first_name ,group_concat(distinct s.companyname) as company_name,
group_concat(distinct s.country )as supplier_country from customer as c
join supplier as s on c.country!=s.country
group by cust_country;

create view sample_view as (select s.companyname,s.country as supplier_name,group_concat(distinct c.firstname),
group_concat(distinct c.country) as cust_country from supplier as s
join customer as c on s.country!=c.country
group by supplier_name);

select * from sample_view;



-- 4.	Every supplier supplies specific products to the customers. 
-- Create a view of suppliers and total sales made by their products and write a query on this view to find out top 2 suppliers 
-- (using windows function RANK() in each country by total sales done by the products.

select s.companyname,p.productname,sum(o.totalamount)from supplier as s
join product as p on s.id=p.supplierid
join orderitem as oi on p.id=oi.productid
join orders as o on oi.orderid=o.id
group by companyname,productname
order by totalamount desc;
