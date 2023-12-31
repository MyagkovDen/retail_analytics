create or replace view customers_avr_check_and_latest_date as
select customer_id,round(avg(transaction_sum), 2) as customer_average_check, max(transaction_datetime) as latest_date
from transactions t join cards c 
on t.customer_card_id = c.customer_card_id group by customer_id;

CREATE VIEW customers_avr_check AS 
SELECT c.customer_id, avg(t.transaction_sum) AS customer_average_check
FROM transactions t
JOIN cards c ON t.customer_card_id = c.customer_card_id
GROUP BY c.customer_id;

create or replace view avr_check_segm as
select customer_id, customer_average_check, 
ntile(3) over(order by customer_average_check desc ) as customer_average_check_segment
from customers_avr_check_and_latest_date;

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

create or replace view customers_avr_frequency as
select customer_id, round(avg_date_diff, 2) as customer_frequency,
ntile(3) over(order by avg_date_diff) as customer_frequency_segment
from avr_freq;

create or replace view churn_rate_and_segm as
with dt as (select cacld.customer_id, customer_frequency, 
(date_part('day', now() - latest_date)) as customer_inactive_period,
(date_part('day', now() - latest_date)/customer_frequency) as customer_churn_rate 
from customers_avr_check_and_latest_date cacld join customers_avr_frequency caf on cacld.customer_id
= caf.customer_id)
select customer_id, customer_frequency, customer_inactive_period, customer_churn_rate,
case 
	when customer_churn_rate < 1 then 'low'
	when customer_churn_rate < 1.5 then 'medium'
	else 'high'	
end customer_churn_segment
from dt;

create view customer_primary_store as
select distinct customer_id, transaction_store_id as customer_primary_store, store_count, max_count, sum_paid, max_costs
from customers_stores
where sum_paid = max_costs;

CREATE VIEW public.customers_stores AS 
with dt as
(SELECT c.customer_id, t.transaction_store_id, 
count(*) over (partition by c.customer_id, t.transaction_store_id) as store_count,
sum(transaction_sum) over (partition by c.customer_id , transaction_store_id order by customer_id) as sum_paid
FROM transactions t 
     JOIN cards c ON t.customer_card_id = c.customer_card_id)
 select customer_id, transaction_store_id,  sum_paid, store_count,
 max(store_count)over (partition by customer_id) as max_count,
 max(sum_paid) over (partition by customer_id) as max_costs
 from dt;

create or replace view customers as
select acg.customer_id, acg.customer_average_check, acg.customer_average_check_segment, 
caf.customer_frequency, caf.customer_frequency_segment,
crs.customer_inactive_period, crs.customer_churn_rate, crs.customer_churn_segment, cps.customer_primary_store
from avr_check_segm acg join customers_avr_frequency  caf on acg.customer_id = caf.customer_id join 
churn_rate_and_segm crs on acg.customer_id = crs.customer_id join customer_primary_store cps on acg.customer_id 
= cps.customer_id
order by acg.customer_id;

