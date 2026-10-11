-- Show the record of Customers,Orders,Products,Order_Details
select * from Customers;
select * from Orders;
select * from Products;
select * from Order_Details;
-- How many customers we have?
select count(Customer_ID)
from Customers;
-- How many male customers we have?
select count(Customer_ID) as male_customer
from Customers
where Gender= 'Male';

-- How many female customers we have?
select count(Customer_ID) as female_customer
from Customers
where Gender= 'Female';

/* How many customers we have in each city? 
Show customer in desc order according to number of customers in each city. */
select City,
count(Customer_ID) as no_of_customer
from Customers
group by City
order by count(Customer_ID) desc;

-- Find the number of customers in each region.
select Region,
count(Customer_ID) as no_of_customer 
from Customers
group by Region
order by no_of_customer  ;

--Find the number of customers in each city and region.
select City,Region,
count(Customer_ID) as no_of_customer 
from Customers
group by City ,Region ;

--How many customers signed up between January 1, 2023 and December 31, 2023?
select count(Customer_ID) as total_customer
from Customers
where Signup_Date between '2023-01-01' and '2023-12-31';

--Categorize customers into different age groups: teenager, adult, and old, based on their age.
select Age,
case 
    when Age >0 and Age<=20 then 'teenager'
    when Age >21 and Age<=45 then 'adult'
    else 'old'
    end as age_category
from Customers;

--Find the total number of orders placed by each customer.

select c.Customer_ID,
count(o.Order_ID) as total_order
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
group by c.Customer_ID;

--Find all customers who have never placed an order.
select c.Customer_ID,c.Customer_Name
from Customers c
left join Orders o
on c.Customer_ID=o.Customer_ID
where o.Customer_ID is null;


--Find the customer who has placed the highest number of orders.
select * from
(select  c.Customer_ID,
count(o.Order_ID) as total_order,
rank () over (order by count(o.Order_ID) desc) as rnk
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
group by c.Customer_ID) t
where rnk=1 ;


/*Calculate the total amount spent by each customer and 
display the customers in descending order of their total spending.*/
select Customer_ID,
SUM(Order_Total) as total_amount
from orders
group by Customer_ID
order by total_amount desc ;

--Find the top 10 customers who have spent the highest total amount, along with their spending rank.
select * from(
select Customer_ID,
SUM(Order_Total) as total_amount,
rank () over(order by SUM(Order_Total) desc) as rank
from orders
group by Customer_ID)r
where rank between 1 and 10;


--Identify customers who placed an order in 2023 but have not placed any order in 2024.
select distinct o.Customer_ID,
o.Order_Date
from Orders o
where Order_Date between '2023-01-01' and '2023-12-31' and
 not exists  
(select *
from Orders o2
where o2.Customer_ID = o.Customer_ID
and o2.Order_Date between '2024-01-01' and '2024-12-31');

--Find customers who have not placed an order in the last 6 months.
select Customer_ID,
max(Order_Date) as last_order
from Orders
group by Customer_ID 
having max(Order_Date)<'2024-06-01';

--Identify customers who have spent more than ₹50,000 in total.
select  Customer_ID ,
sum(Order_Total) total_spend
from Orders
group by Customer_ID
having sum(Order_Total)>50000;

--Categorize customers into Low, Medium, and High-value customers based on their total spending.
select  Customer_ID ,
sum(Order_Total) total_spend,
case 
    when sum(Order_Total)>0 and sum(Order_Total)<=20000 then 'low'
     when sum(Order_Total)>20001 and sum(Order_Total)<=50000 then 'mediam'
     else 'high'
     end as category_of_customer
from Orders
group by Customer_ID

--Find customers who have placed at least 3 orders.

select Customer_ID, 
count(Order_ID)  as total_order
from Orders 
group by Customer_ID
having count(Order_ID)>=3;

--Identify customers who placed exactly one order.
select Customer_ID, 
count(Order_ID)  as total_order
from Orders 
group by Customer_ID
having count(Order_ID)=1

--Find the top 10 products based on total quantity sold.
select * from
(select Product_ID,
sum (Quantity) total_quantity,
rank() over(order by sum (Quantity) desc) rank_of_quantity_sold
from Order_Details
group by Product_ID)t
where rank_of_quantity_sold<=10;

--Find the top 10 products that generated the highest revenue.
select * from
(select Product_ID,
sum (Line_Total) total_revenue,
rank() over(order by sum (Line_Total) desc) rank_of_revenue
from Order_Details
group by Product_ID)t
where rank_of_revenue<=10;

--Identify products that have been ordered fewer than 5 times.

select Product_ID,
count(Order_Detail_ID) ordered_product
from Order_Details
group by Product_ID 
having count(Order_Detail_ID)<5;

--Calculate total revenue generated by each product category and identify the highest-performing category.
select p.Category,
sum(o.Line_Total) as category_revenue
from Products p
inner join Order_Details as o
on p.Product_ID=o.Product_ID
group by Category
order by sum(o.Line_Total) desc;

--Find the most frequently purchased product in each category.
select * from(
select p.Category, 
p.Product_ID,
p.Product_Name,
count(Order_Detail_ID) no_of_order,
rank() over(partition by Category order by count(Order_Detail_ID) desc ) as rnk
from Order_Details o
join Products p
on o.Product_ID= p.Product_ID
group by
p.Category,
p.Product_ID,
p. Product_Name) t
where rnk=1
;


--Find products whose unit price is higher than the average price of all products.
 select Product_Name,
 Unit_Price
 from Products
 where Unit_Price> (select AVG(Unit_Price) from Products);

 --Calculate monthly revenue and identify the month with the highest revenue.

 select* from(
 select 
 year(Order_date) as year,
 month(Order_date) as month,
 sum(Order_Total) order_total_month,
 rank() over(order by sum(Order_Total)desc) as rnk
 from Orders
 group by  year(Order_date) ,month(Order_date)) t
 where rnk=1
  ;

 -- Calculate the percentage change in revenue between 2023 and 2024.

select 
       round(((revenue_2024-revenue_2023)/revenue_2023)*100 ,2)as percent_change
 from(
 select 
 sum(case 
          when year(Order_Date)='2023' then Order_total
          else 0
          end) as revenue_2023,
 sum(case 
          when year(Order_Date)='2024' then Order_total
          else 0
          end) as revenue_2024
 from Orders)t;

 --Find which region generates the highest total sales.
 select * from(
 select Region,
 sum(Order_Total) total_revenue,
 rank() over(order by sum(Order_Total) desc) rnk
 from Customers c
 join Orders o
 on c.Customer_ID=o.Customer_ID
 group by Region) t
 where rnk=1;

 --Calculate the average order value for each month.
 select year(Order_Date) order_year,
 month(Order_Date) order_month,
 round(avg(Order_Total),2) average_revenue
 from Orders
 group by year(Order_Date),
 month(Order_Date) 
 order by  year(Order_Date),
 month(Order_Date) ;

 --Identify the highest-spending customer in each region.
 
 select * from (
 select Region,
 Customer_Name,
 sum(Order_Total) total_revenue,
 rank() over( partition by Region order by sum(Order_Total) desc) rnk
 from Customers c
 join Orders o
 on c.Customer_ID=o.Customer_ID
 group by Region,
 Customer_Name)t
 where rnk=1;

-- Calculate what percentage of total company revenue comes from each product category.
select Category,
sum(Line_Total) total_revenue,
round((sum(Line_Total)/(select sum(Line_Total) from Order_Details))*100.0,2) percent_of_category
from Products p
join Order_Details o 
on p.Product_ID=o.Product_ID
group by Category

--Find the number of new customers acquired each month based on their signup date.

select year(Signup_Date) year_of_signup,
datename(month,Signup_Date) month_of_signup,
count(datename(month,Signup_Date)) no_of_customer
from Customers
group by year(Signup_Date),
datename(month,Signup_Date)
order by year(Signup_Date),
datename(month,Signup_Date);


--Calculate the percentage of orders that were cancelled in each month.
select year(Order_Date) year_of_order,
datename(month,Order_Date) month_of_date,
count(case
           when Order_Status='Cancelled' then Order_ID
           end)*100/count(Order_ID) percent_of_order_cancelled
from Orders
group by year(Order_Date),
datename(month,Order_Date)
order by year(Order_Date),
datename(month,Order_Date);

--Find customers who purchased products previously but have not made a purchase in the last 90 days.
select Customer_ID,
max(Order_Date) as last_day
from Orders 
group by customer_ID
having max(Order_Date)<dateadd(day,-90,getdate())

--Find the top 3 highest-spending customers within each region.
select * from(
select Region,
Customer_Name,
sum(Order_Total) total_revenue,
rank() over(partition by Region order by sum(Order_Total) desc) as rnk
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
group by Region,
Customer_Name)t
where rnk<4;

--Find the best-selling product by quantity for each month.
select * from (
select year(Order_Date) year_of_order,
month(Order_Date) month_of_order,
Product_Name,
sum(Quantity) sold_quantity,
rank() over(partition by year(Order_Date),
month(Order_Date) order by sum(Quantity) desc) rnk
from Orders o
join Order_Details d
on o.Order_ID=d.Order_ID
join Products p
on d.Product_ID=p.Product_ID
group by year(Order_Date),
month(Order_Date),
Product_Name)t
where rnk=1

--Find customers who purchased the same product more than once.
select c.Customer_Name,
d.Product_ID,
count(Product_ID) no_of_purchase
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
join Order_Details d
on d.Order_ID=o.Order_ID
group by Customer_Name,
Product_ID
having count(Product_ID)>1

--Calculate the total revenue generated by each customer and rank them based on lifetime value.

select 
c.Customer_ID,
Customer_Name,
sum(Order_total) total_revenue,
rank() over(order by sum(Order_total) desc ) as rnk
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
group by
c.Customer_ID,
Customer_Name 

--Compare the revenue generated by each product category between 2023 and 2024 and identify categories with declining revenue.
select 
Category,
sum(case 
        when year(Order_Date)='2023' then Line_Total
        else 0
        end)  total_revenue_2023,
sum(case 
        when year(Order_Date)='2024' then Line_Total
        else 0
        end)  total_revenue_2024
from Orders o
join Order_Details d
on o.Order_ID=d.Order_ID
join Products p
on p.Product_ID=d.Product_ID
group by
Category
having sum(case 
        when year(Order_Date)='2023' then Line_Total
        else 0
        end)  >
sum(case 
        when year(Order_Date)='2024' then Line_Total
        else 0
        end)  

--Identify customers who made purchases in 2023 but have never purchased again after 2023.
select 
c.Customer_ID,
c.Customer_Name
from Customers c
join Orders o
on c.Customer_ID=o.Customer_ID
group by c.Customer_ID,
c.Customer_Name
having sum(case 
                when year(Order_Date)='2023' then 1
                else 0
                end) >0
                and
sum(case 
                when year(Order_Date)>'2023' then 1
                else 0
                end)=0

--Determine what percentage of total revenue is generated by the top 10% of customers.
with customer_revenue as(
select 
c.Customer_ID,
c.Customer_Name,
coalesce(sum(o.Order_Total),0) lifetime_revenue
from Customers c
left join Orders o
on c.Customer_ID=o.Customer_ID
group by 
c.Customer_ID,
c.Customer_Name),
ranked_customer as(
select
Customer_ID,
Customer_Name,
lifetime_revenue,
row_number() over(order by lifetime_revenue desc,Customer_Name) rn,
count(*) over() total_customer,
sum(lifetime_revenue) over() company_revenue
from customer_revenue)
select
 round(100*sum(case
                when rn<=CEILING(total_customer*0.10) then lifetime_revenue
                else 0
                end)/nullif(max(company_revenue),0),2) as  top_10_percent_revenue_share
from ranked_customer