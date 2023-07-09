create view customers as
select customer_id,avg(transaction_sum) as customer_average_check
from transactions t join cards c 
on t.customer_card_id = c.customer_card_id group by customer_id;

create view avr_check_segm as
select customer_id, customer_average_check, 
ntile(3) over(order by customer_average_check desc ) as customer_average_check_segment
from customers;

alter view customers rename  to customers_avr_check;