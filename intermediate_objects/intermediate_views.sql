create view customers as
select customer_id,avg(transaction_sum) as customer_average_check
from transactions t join cards c 
on t.customer_card_id = c.customer_card_id group by customer_id;

create view avr_check_segm as
select customer_id, customer_average_check, 
ntile(3) over(order by customer_average_check desc ) as customer_average_check_segment
from customers;

create view customers_frequency as
select customer_id, transaction_datetime,
extract ('day' from (date_trunc('day', lead(transaction_datetime) 
over(partition by customer_id order by transaction_datetime)) - date_trunc('day',  transaction_datetime))) 
as date_diff
from transactions t join cards c 
on t.customer_card_id = c.customer_card_id
order by customer_id;

create view avr_freq as
select customer_id, avg(date_diff)::decimal as avg_date_diff
from customers_frequency 
group by customer_id;

create view customers_avr_frequency as
select customer_id, round(avg_date_diff, 2),
ntile(3) over(order by avg_date_diff) as customer_frequency_segment
from avr_freq;


