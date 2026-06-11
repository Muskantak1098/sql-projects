-- Change over time analysis
-- Analyze sales performance over time

/*
select year(order_date) as year,sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers from gold.fact_sales
where year(order_date) is not null
group by year(order_date)
order by year(order_date);

-- Cumulative Analysis:-
-- Calculate the total sales per month and the running total of sales over time

select datetrunc(month,order_date) as month_year,sum(sales_amount) as total_sales,avg(price) as avg_price
from gold.fact_sales where order_date is not null
group by datetrunc(month,order_date);   

select month(order_date) as months,price,avg(price)as avg_price from gold.fact_sales
group by month(order_date),price;

-- Performance Analysis:-
-- Analyze the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year's sales

WITH yearly_product_sales AS (
select year(f.order_date) as order_year,
p.product_name,sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p on f.product_key=p.product_key
where f.order_date  is not null
group by year(f.order_date),p.product_name)

select order_year,
product_name,
current_sales,
avg(current_sales)over(partition by product_name) as avg_sales,
current_sales-avg(current_sales) over(partition by product_name) as diff_avg,
CASE when current_sales-avg(current_sales) over(partition by product_name)>0 then 'above_avg'
     when current_sales-avg(current_sales) over(partition by product_name)<0 then 'below_avg'
     else 'avg'
end avg_col,
--year_over_year analysis
lag(current_sales) over(partition by product_name order by order_year) as py_sales,
current_sales-lag(current_sales) over(partition by product_name order by order_year) as diff_year,
case when current_sales-lag(current_sales) over(partition by product_name order by order_year)>0 then 'Increase'
 when current_sales-lag(current_sales) over(partition by product_name order by order_year) <0 then 'Decrease'
else 'No_change'
end  py_change
from yearly_product_sales
order by product_name,order_year;

-- Part to whole analysis:-
-- which categories contribute the most to overall sales:---

with category_sales as(
select p.category,sum(f.sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p on f.product_key=p.product_key
group by p.category)

select category,total_sales,sum(total_sales) over() as overall_sales,
concat(round((cast(total_sales as float)/sum(total_sales) over())*100,2),'%') as percentage_of_total
from category_sales
order by total_sales desc;


-- Data Segmentation
-- segment products into cost ranges and count how many products fall into each segment

with product_segment as(
select product_key,product_name,cost,
case when cost<100 then 'below 100'
 when cost between 100 and 500 then '100-500'
 when cost between 500 and 1000 then '500-1000'
 else 'above 1000'
 end cost_ranges
from gold.dim_products)

select cost_ranges,count(product_key) as products_counts from product_segment
group by cost_ranges
order by products_counts desc;

-- Group customers into 3 segments:
--1 VIP - At least 12 months of history and spending more than 5000
--2 Regular - ''''' but spending 5000 or less 
-- 3 New - lifespan less than 12 months
-- and find the total  no. of customers by each group

--1
with customers_spendings as (
select c.customer_key,sum(f.sales_amount) as total_spending,min(f.order_date) as min_date,max(f.order_date) as max_date,
datediff(month,min(order_date),max(order_date)) as life_span
from gold.fact_sales f
left join gold.dim_customers c 
on f.customer_key=c.customer_key
group by c.customer_key)



select customer_segment,count(customer_key) as total_customers from 
(select customer_key,total_spending,life_span,
case when life_span>=12  and total_spending >5000 then 'VIP'
when life_span >=12 and total_spending <=5000 then 'Regular'
else 'New'
end customer_segment
from customers_spendings) t
group by customer_segment
order by total_customers desc;



-- CUSTOMER REPORT--

--1 Gathers essential fields such as names,ages and transaction details

CREATE VIEW gold.report_customers as 
with base_query as (select f.order_number,f.product_key,f.order_date,f.sales_amount,f.quantity,
c.customer_key,c.customer_number,concat(c.first_name,' ',last_name) as customer_name,datediff(year,c.birthdate,getdate()) as age
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
where f.order_date is not null),

--2 Aggregate customer level metrics 

customer_aggregations as(
 select customer_key,customer_name,age,
 count( distinct order_number) as total_orders,
 count(distinct product_key) as total_products,
 sum(sales_amount) as total_sales,
 sum(quantity) as total_quantity,
 datediff(month,min(order_date),max(order_date)) as life_span,
 max(order_date) as last_order_date
 from base_query
 group by customer_key,customer_name,age)

 -- 3 Segment customers into categories (VIP,Regular,New) and age group

select customer_key,customer_name,age,
total_orders,total_products,total_sales,total_quantity,
case when age < 20 then 'Under 20'
when age between 20 and 29 then '20-29'
when age between 30 and 49 then '30-49'
else 'above 50'
end as age_group,

case when life_span>=12  and total_sales >=5000 then 'VIP'
when life_span >=12 and total_sales <=5000 then 'Regular'
else 'New'
end as customer_segment,
last_order_date,
--4 Valuable KPIs (1) recency month since last_order  (2) Average order value (3) Average monthly spend

datediff(month,last_order_date,getdate()) as recency,           --recency 

case when total_orders=0 then '0'                               -- average_order_value
else total_sales/total_orders
end as average_order_value,
case when life_span=0 then total_sales                         --average_monthly _spend
else total_sales/life_span
end as avearge_monthly_spend
from customer_aggregations;

*/

-- PRODUCT_REPORT

--Gathers essential fields----

Create view gold.report_products as
with base_products as(
select f.order_number,f.order_date,f.customer_key,f.sales_amount,f.quantity,
p.product_key,p.product_name,p.category,p.subcategory,p.cost
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where order_date is not null),

-- Aggregates product level metrics:--

products_aggregation as (
select product_key,product_name,category,subcategory,cost,
datediff(month,min(order_date),max(order_date)) as life_span,
max(order_date) as last_sale_date,
count(distinct customer_key) as total_customers,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
round(avg(cast(sales_amount as float)/nullif(quantity,0)),1) as avg_sales
from base_products
group by product_key,product_name,category,subcategory,cost )


-- Calculate valuable KPIs
select product_key,product_name,category,subcategory,cost,last_sale_date,
datediff(month,last_sale_date,getdate()) as recency_pr_days,                 -- recency(months of last sales)
case when total_sales>50000 then 'high preformer'
when total_sales>=10000 then 'mid performer'
else 'low performer'
end as products_segments,
life_span,
total_customers,
total_orders,
avg_sales,
case when total_orders=0 then '0'                               -- average_order_value
else total_sales/total_orders
end as average_order_revenue,

case when life_span=0 then total_sales                         --average_monthly _spend
else total_sales/life_span
end as avearge_monthly_revenue
from products_aggregation;







