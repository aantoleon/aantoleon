select * from city;

select * from customers;

select * from products;

select * from sales;

-- find the coffee counseming percentage 

select city_name,
round((population * 0.25) / 10000000 ,2) as coffee_counseming_percentage,
city_rank
from city
order by 2 desc;

show tables;

use shop;

-- find a quater sales form 2023

select *,
	extract(year from sale_date) as year,
    extract(quarter from sale_date) as qtr
from sales
where
	extract(year from sale_date) = 2023
    and
    extract(quarter from sale_date) = 4
    
-- find a total revenue  

select 
	sum(total) as Total_revenue
from sales
where
	extract(year from sale_date) = 2023
    and
    extract(quarter from sale_date) = 4

select * from city

select 
	ci.city_name,
    sum(s.total) as Total_revenue
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
where
	extract(year from sale_date) = 2023
    and
    extract(quarter from sale_date) = 4
group by 1
order by 2 desc

-- find how many products are sold in the shop

select * from products;

select
	p.product_name,
    count(s.sale_id) as total_sale
from products as p
left join
sales as s
on s.product_id = p.product_id
group by 1
order by 2 desc

-- average sales amount in customer per city

select
	ci.city_name,
    sum(s.total) as Total_revenue,
    count(distinct s.customer_id) as Total_cnt,
    round(sum(s.total)/count(distinct s.customer_id),2) as avg_sale_per_city
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc

-- find the city popultion and coffee counsemers

with city_table as
(select city_name,
	round((population * 0.25)/1000000, 2) as coffee_consumers
from city),
customer_table
as    
(select ci.city_name,
	count(distinct c.customer_id) as unique_cust
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1)
select 
	customer_table.city_name,
    city_table.coffee_consumers as coffee_consumers_in_milions,
    customer_table.unique_cust
from city_table
join customer_table
on city_table.city_name = customer_table.city_name;

-- top selling products of each city and top 3 products selling for each city based on the sales volume
select * from
(select
	ci.city_name,
    p.product_name,
    count(s.sale_id) as total_orders,
    dense_rank() over(partition by ci.city_name order by count(s.sale_id) desc) as mark 
from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,2) as t1
where mark <= 3


-- find the unique members are purchaseing the coffee products of each city

select  
	ci.city_name,
    count(distinct c.customer_id) as unique_cust
from city as ci
left join 
customers as c
on c.city_id = ci.city_id
join sales as s
on s.customer_id = c.customer_id
where 
	s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1
order by 2 desc

-- find the each city and they average sale per customer and avg rent per cusomer

with city_table
as
(select
	ci.city_name,
    sum(s.total) as Total_revenue,
    count(distinct s.customer_id) as Total_cnt,
    round(sum(s.total)/count(distinct s.customer_id),2) as avg_sale_per_city
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc),
city_rent
as
(select 
	city_name,
    estimated_rent
from city)
select
	cr.city_name,
    cr.estimated_rent,
    ct.Total_cnt,
    ct.avg_sale_per_city,
    round(cr.estimated_rent /ct.Total_cnt,2) as avg_ren_per_cnt
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 4 desc ;

-- monthly growth ratio of each city

with
monthly_sales
as
(select 
	ci.city_name,
    extract(month from sale_date) as month,
    extract(year from sale_date) as year,
    sum(s.total) as total_sale 
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1,2,3
order by 1,2,3),

growth_ratio
as
(select
	city_name,
    month,
    year,
    total_sale as cr_month_sale,
    lag(total_sale,1) over (partition by city_name order by year, month) as last_month_sale
from monthly_sales)
select
	city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    round((cr_month_sale-last_month_sale)/last_month_sale*100 ,2) as growth_ratio
from growth_ratio
where last_month_sale is not null

-- find the market potenital analysis and find the top 3 city for best sale in over a year

with city_table
as
(select
	ci.city_name,
    sum(s.total) as Total_revenue,
    count(distinct s.customer_id) as Total_cnt,
    round(sum(s.total)/count(distinct s.customer_id),2) as avg_sale_per_city
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc),
city_rent
as
(select 
	city_name,
    estimated_rent,
    round((population * 0.25)/1000000,3) as  estimated_coffee_consumer_in_milions
from city)
select
	cr.city_name,
    total_revenue,
    cr.estimated_rent as total_rent,
    ct.Total_cnt,
    estimated_coffee_consumer_in_milions,
    ct.avg_sale_per_city,
    round(cr.estimated_rent /ct.Total_cnt,2) as avg_ren_per_cnt
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 2 desc ;


		