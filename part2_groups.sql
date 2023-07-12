WITH gs AS (
	WITH gsp AS (
		SELECT c.customer_id, group_id, 
		sum(sku_sum_paid) AS group_sum_paid,
		sum(sum(sku_sum_paid)) over(PARTITION BY c.customer_id) AS overall_sum,
		(date_part('day', (max(transaction_datetime) - min(transaction_datetime)) / count(*))+1)
		AS frequency_rate,
		(date_part('day', (now() - max(transaction_datetime)))+1) AS inactive_period
	FROM cards c 
		JOIN transactions t ON c.customer_card_id = t.customer_card_id 
		JOIN checks c2 ON t.transaction_id = c2.transaction_id  
		JOIN product_grid pg  ON c2.sku_id = pg.sku_id 
	GROUP BY customer_id, group_id
	)
	SELECT customer_id, 
		group_id, 
		group_sum_paid/overall_sum AS group_share,
		inactive_period / frequency_rate AS churn_rate
	FROM gsp
)
SELECT customer_id, group_id, 
	rank() OVER (PARTITION BY customer_id ORDER BY group_share DESC ) AS group_affinity_index,
	rank() OVER (PARTITION BY customer_id ORDER BY churn_rate DESC ) AS group_churn_rate
FROM gs
ORDER BY customer_id, group_id;

WITH stab_rate AS (
	WITH avr_freq as(
		WITH purchases_intervals AS (
			SELECT customer_id, group_id, transaction_datetime ,
				EXTRACT (DAY FROM (LEAD (transaction_datetime) OVER(PARTITION BY 
				customer_id , group_id) - transaction_datetime)) +1 AS purchase_interval
			FROM cards c 
				JOIN transactions t ON c.customer_card_id = t.customer_card_id 
				JOIN checks c2 ON t.transaction_id = c2.transaction_id 
				JOIN product_grid pg ON c2.sku_id = pg.sku_id 
			GROUP BY customer_id , group_id, transaction_datetime
			ORDER BY customer_id , group_id, transaction_datetime
		)
		SELECT customer_id, group_id, purchase_interval, 
			AVG (purchase_interval) over(PARTITION BY customer_id, group_id) AS avr_frequency
		FROM purchases_intervals
	)
	SELECT customer_id, group_id,purchase_interval, avr_frequency,
		ABS(purchase_interval-avr_frequency) AS avr_diff
	FROM avr_freq
)
SELECT customer_id, group_id,
	sum(avr_diff) / count (*) AS stability_rate
FROM stab_rate
WHERE avr_diff NOTNULL 
GROUP BY customer_id, group_id
ORDER BY customer_id, group_id;



