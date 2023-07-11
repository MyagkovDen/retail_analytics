create view periods_without_frequncy as
select c.customer_id , pg.group_id , min(t.transaction_datetime) as first_group_purchase_date,
max(t.transaction_datetime) as last_group_purchase_date, count(t.transaction_id) as group_purchase
from cards c join transactions t on c.customer_card_id = t.customer_card_id join checks c2 on t.transaction_id 
= c2.transaction_id join product_grid pg on c2.sku_id = pg.sku_id 
group by c.customer_id , pg.group_id 
order by c.customer_id , pg.group_id ;

create view periods as
with pwf as (select customer_id, group_id, first_group_purchase_date, last_group_purchase_date, group_purchase,
sum(group_purchase) over(partition by customer_id) as overall_cost
from periods_without_frequncy)
select customer_id, group_id, first_group_purchase_date, last_group_purchase_date, group_purchase, 
round((group_purchase / overall_cost * 100), 2) as group_frequency
from pwf;

