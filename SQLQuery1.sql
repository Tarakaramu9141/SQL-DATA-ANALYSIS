Select *from project.dbo.transactions

alter table transactions
alter column transaction_date date; --To change the type into date

alter table transactions
alter column transaction_time time;

select count(product_category)  from transactions
where product_Category = 'coffee'

--Calculating total sales

select sum(unit_price * transaction_qty) as total_sales
from transactions

--Gives the sum of totalsales in the month of May and approximate value removing decimals
select round(sum(unit_price * transaction_qty),0) as total_sales
from transactions
where month(transaction_date) 

--for growth rate_percentage  for every month in the data

SELECT
    month(transaction_date) AS month,
    (SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY month(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY month(transaction_date))*100 AS growth_rate_percentage
FROM
    transactions
GROUP BY
    month(transaction_date)
ORDER BY
    month;

	--To check the total orders got by each month in a separate table
Select
count(transaction_id) as Total_order,month(transaction_Date)  as month
from transactions

group by month(transaction_date)
order by month(transaction_Date)

--To check the monthly or increase or decrease in orders

SELECT
    month(transaction_date) AS month,
    round(count(transaction_id),1) AS total_orders,
    (count(transaction_id) - LAG(count(transaction_id),1) OVER (ORDER BY month(transaction_date))) / LAG(count(transaction_id),1) OVER (ORDER BY month(transaction_date)) * 100 AS order_growth_percent
FROM
    transactions

GROUP BY
    month(transaction_date)
order by 
	month(transaction_date)

--To check the total quantity sold in each month

Select
sum(transaction_qty) as Total_qty,month(transaction_Date)  as month
from transactions

group by month(transaction_date)
order by month(transaction_Date)

--To check the difference in the number of orders between the selected month and the previous month

SELECT
    month(transaction_date) AS month,
    round(sum(transaction_qty),1) AS total_qty,
    (sum(transaction_qty) - LAG(sum(transaction_qty),1)
	OVER (ORDER BY month(transaction_date))) / LAG(sum(transaction_qty),1)
	OVER (ORDER BY month(transaction_date)) * 100 AS quantity_growth_percent
FROM
    transactions

GROUP BY
    month(transaction_date)
order by 
	month(transaction_date)


--Let's do the sales analysis by weekdays and weekends


select
case when datepart(weekday,transaction_date) in (1,7) then 'weekends'
else 'weekdays'
end as day,
sum(unit_price*transaction_qty) as total_sales
from transactions
where month(transaction_date) like 5
group by
case when datepart(weekday,transaction_date) in (1,7) then 'weekends'
else 'weekdays'
end

--To check the data based on the store location

select
store_location,
sum(unit_price*transaction_qty) as total_sales
from transactions

group by store_location 
order by sum(unit_price*transaction_qty) 


--Taking the average sales performance
select
avg(total_sales) as avg_sales
from
(
select sum(unit_price*transaction_qty) as total_sales
from transactions 
where month(transaction_DAte)=2
group by transaction_Date
) as internal_query


select day(transaction_Date) as day_of_month,
sum(unit_price*transaction_qty) as total_sales
from transactions
group by day(transaction_Date)
order by day(transaction_Date)

--Checking whether average sales is below or average or above
select
day_of_month,
case
when total_sales>avg_sales then 'Above Average'
when total_sales<avg_sales then 'Below Average'
else 'Average'
end as sales_status,
total_sales
from 
(
select
day(transaction_Date) as day_of_month,
sum(unit_price*transaction_qty) as total_sales,
avg(sum(unit_price*transaction_qty)) over () as avg_sales
from transactions
group by 
day(transaction_date)
)as sales_data
group by
day_of_month


--Checking the sales by product category

select
product_category, sum(unit_price*transaction_qty) as total_sales
from transactions
group by product_category
order by sum(unit_price*transaction_qty)

--Checking the top  slling products
select top 10
product_type, sum(unit_price*transaction_qty) as total_sales
from transactions
group by product_type
order by sum(unit_price*transaction_qty)

--Checking the sales by hourly basis

select
sum(unit_price*transaction_qty) as total_sales,
sum(transaction_qty) as total_qty_sold,
count(*) as transaction_count
from transactions
where 
 datepart(hour,transaction_time)=7

 --showing the sales by hourly basis

 select datepart(hour,transaction_time),
 sum(unit_price*transaction_qty) as total_sales
 from transactions
 group by datepart(hour,transaction_time)
 order by datepart(hour,transaction_time)