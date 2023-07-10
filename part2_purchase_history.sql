create view purchase_history as
with g as 
(select c.transaction_id , pg.group_id , sum(pg.sku_purchase_price * sku_amount) as group_cost, sum(sku_sum) 
as group_sum, sum(sku_sum_paid) as group_sum_paid from checks c join 
product_grid pg on c.sku_id = pg.sku_id 
group by c.transaction_id, pg.group_id)
select pi12.customer_id , t.transaction_id , t.transaction_datetime, g.group_id, g.group_cost, g.group_sum, 
g.group_sum_paid
from personal_information pi12 join
cards c on pi12.customer_id = c.customer_id join transactions t on c.customer_card_id = t.customer_card_id join 
g on t.transaction_id = g.transaction_id
order by customer_id, transaction_id, group_id;