SELECT * FROM `e-commerce`.customers;

with count_per_order as
(select orders.order_id, orders.customer_id, count(order_items.order_id) as oc
from orders join order_items
on orders.order_id = order_items.order_id
group by orders.order_id, orders.customer_id)
select customers.customer_city, round(avg(count_per_order.oc),2) average_orders
from customers join count_per_order
on customers.customer_id = count_per_order.customer_id
group by customers.customer_city;


select upper(products.product_category) category,
round((sum(payments.payment_value)/ (select sum(payments.payment_value) from payments))*100,2) sales_percentage
from products join order_items
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales_percentage desc;


select products.product_category,
count(order_items.product_id),
round(avg(order_items.price),2)
from products join order_items
on products.product_id = order_items.product_id
group by products.product_category;

 select customer_id, order_id, order_purchase_timestamp, order_value,
 avg(order_value) over(partition by customer_id order by order_purchase_timestamp rows between 2 preceding and current row)
 as moving_average
 from (select orders.customer_id, orders.order_id, orders.order_purchase_timestamp, sum(order_items.price) as order_value
 from orders join order_items
 on orders.order_id = order_items.order_id
 group by orders.customer_id, orders.order_id, orders.order_purchase_timestamp)
 as result 
 order by customer_id, order_purchase_timestamp;


with a as (select customers.customer_id,
min(orders.order_purchase_timestamp) first_order
from customers join orders
on customers.customer_id = orders.customer_id
group by customers.customer_id),
 
b as (select a.customer_id, count(distinct orders.order_purchase_timestamp) next_order
from a join orders 
on orders.customer_id = a.customer_id 
and orders.order_purchase_timestamp > first_order
and orders.order_purchase_timestamp < 
date_add(first_order, interval 6 month)
group by a.customer_id) 
select 100 * (count(distinct a.customer_id)/ count(distinct b.customer_id))
from a left join b
on a.customer_id = b.customer_id ;

select *, dense_rank() over(order by revenue desc) as rn from
(select order_items.seller_id, sum(payments.payment_value)
revenue from order_items join payments
on order_items.order_id = payments.order_id
group by order_items.seller_id) as a;

select orders.customer_id, orders.order_purchase_timestamp,
payments.payment_value
from payments join orders
on payments.order_id = orders.order_id;

select customer_id, order_purchase_timestamp, payment,
avg(payment)over(partition by customer_id order by order_purchase_timestamp
rows between 2 preceding and current row) as mov_avg
from 
(select orders.customer_id, orders.order_purchase_timestamp,
payments.payment_value as payment
from payments join orders
on payments.order_id = orders.order_id) as a;


select years, customer_id, payment, d_rank
from
(select year(orders.order_purchase_timestamp) years,
orders.customer_id,
sum(payments.payment_value) payment,
dense_rank() over (partition by  year(orders.order_purchase_timestamp) 
order by sum(payments.payment_value) desc) d_rank
from orders join payments
on payments.order_id = orders.order_id
group by year(orders.order_purchase_timestamp),
orders.customer_id) as a
where d_rank <= 4 ;

select upper(p.product_category) as category,
round(sum(pay.payment_value), 2) as sales
from `e-commerce`.products as p
join `e-commerce`.order_items as oi
on p.product_id = oi.product_id
join `e-commerce`.payments as pay
on pay.order_id = oi.order_id
group by p.product_category;

select products.product_category,
SUM(payments.payment_value) AS
sales
From products
 JOIN order_items
      ON products.product_id = 
      order_items.product_id
      JOIN payments
      ON payments.order_id = 
      order_items.order_id
GROUP BY products.product_category;


select upper (products.product_category) category,
round(sum(payments.payment_value)/(select sum(payment_value) from payments))*100 as sales
from `e-commerce`.products join `e-commerce`.order_items
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales limit 2;
