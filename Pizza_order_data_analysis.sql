-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_order
FROM
    orders;

-- Identify the highest-priced pizza.
SELECT 
    *
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS total_sales
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;

-- Determine the distribution of orders by hour of the day.
select extract(hour from order_time) as day_of_hour, count(order_id) as total_hour_order
from orders
group by day_of_hour
order by total_hour_order desc;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as order_count from pizzas
inner join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc limit 1;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) as most_ordered from pizzas
inner join order_details
on pizzas.pizza_id = order_details.pizza_id
inner join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by most_ordered desc limit 1;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
select extract(hour from order_time) as day_of_hour, count(order_id) as total_hour_order
from orders
group by day_of_hour
order by total_hour_order desc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as total_pizzas
from pizza_types 
group by category
order by total_pizzas desc;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(subquery.total_order), 0) from (select o.order_date, sum(od.quantity) as total_order
from orders as o
inner join order_details as od
on o.order_id = od.order_id
group by o.order_date) as subquery;

-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, round(sum(p.price * od.quantity), 2) as revenue_per_pizzatype
from pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue_per_pizzatype desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, round(sum(p.price * od.quantity) / (SELECT 
    SUM(pizzas.price * order_details.quantity) 
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100, 2) as revenue_per_pizzatype
from pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by revenue_per_pizzatype desc;

-- Analyze the cumulative revenue generated over time.
select o.order_date,  
    ROUND(SUM(p.price * od.quantity),
            2) AS sales_in_day,
            round(sum(SUM(p.price * od.quantity)) OVER (ORDER BY order_date), 2)
            AS cummulative_sale_overtime
FROM
    pizzas as p
        INNER JOIN
    order_details as od ON p.pizza_id = od.pizza_id
    inner join orders as o on od.order_id = o.order_id 
    group by o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue_per_pizzatype from (select category, name, revenue_per_pizzatype, 
rank() over(partition by category order by revenue_per_pizzatype desc) as rank_cat
from
 (select pt.name, pt.category, round(sum(p.price * od.quantity), 2) as revenue_per_pizzatype
from pizzas AS p
        INNER JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
group by pt.category, pt.name
order by revenue_per_pizzatype desc) as sq) as sq2
where rank_cat <= 3;