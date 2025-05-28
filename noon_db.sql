select * from orders;
-- 1. Find Top 3 Outlets By Cuisine Type without using limit and top function
with cte as (
select Cuisine, Restaurant_id, count(*) as no_of_orders from orders
group by Cuisine, Restaurant_id)
select * from(
select *, row_number() over(partition by Cuisine order by no_of_orders desc) as rn from cte) a
where rn < 3;



-- 2. Find the Daily new customers count from launch date(everyday how many new customers are we acquiring).
with cte as (
select Customer_code, cast(min(Placed_at) AS date) as first_order_date from orders
group by Customer_code
)
select first_order_date, count(*) as no_of_new_customers from cte
group by first_order_date
order by first_order_date;



-- 3. count all the users who were acquired in Jan 2025 and only placed one order in Jan and did not place any other order.
select Customer_code, count(*) as no_of_orders from orders
where month(Placed_at) = 1 and year(Placed_at) = 2025 
and Customer_code not in( select distinct Customer_code from orders
where not (month(Placed_at) = 1 and year(Placed_at) = 2025))
group by Customer_code
having count(*) = 1;



-- 4. List All Customers with no order in the last 7 days but were acquired one month ago with their first order on promo.
with cte as (
select Customer_code, min(Placed_at) as first_order_date, max(Placed_at) as latest_order_date from orders	
group by Customer_code)
select cte.*, orders.Promo_code_Name from cte
inner join orders on cte.Customer_code = orders.Customer_code and cte.first_order_date = orders.Placed_at
where latest_order_date < curdate() - interval 7 day and
first_order_date < curdate() - interval 1 month and orders.Promo_code_Name is not null;



-- 5. Growth team is planning to create a trigger that will target customers after their every 
-- third order with a personalized communication and they have asked you to create a query for this.
with cte as (
select *, row_number() over(partition by Customer_code order by Placed_at) as order_number from orders
)
select * from cte
where order_number %3 = 0 and cast(Placed_at as date) = cast(curdate() as date);



-- 6. List Customers who placed more than 1 order and all their orders on promo only.
select Customer_code, count(*) as no_of_orders, count(Promo_code_Name) as promo_orders from orders
group by Customer_code
having count(*) > 1 and count(*) = count(Promo_code_Name);




-- 7. What Percent of Customers were organically  acquired in jan 2025. (Placed their first order without promo code).
with cte as (
select *, row_number() over(partition by Customer_code order by Placed_at) as rn from orders 
where month(Placed_at) = 1
)
select (count(case when rn = 1 and Promo_code_Name is null then Customer_code end)*100.0 / count(distinct Customer_code)) as Percentage_of_customers_who_placed_their_first_order_without_promo_code from cte;












