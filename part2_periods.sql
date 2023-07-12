CREATE OR REPLACE VIEW periods AS
	WITH purchases_periods AS (
		SELECT customer_id, 
			(MAX(transaction_datetime) - MIN(transaction_datetime))  purchase_period
		FROM cards c 
			JOIN transactions t ON c.customer_card_id = t.customer_card_id 
			JOIN checks c2 ON t.transaction_id = c2.transaction_id 
		GROUP BY customer_id
	)
	SELECT c.customer_id , pg.group_id , 
		MIN(t.transaction_datetime) AS first_group_purchase_date,
		MAX(t.transaction_datetime) AS last_group_purchase_date, 
		COUNT(t.transaction_id) AS group_purchase,
		(DATE_PART('day', purchase_period / COUNT(t.transaction_id)) + 1) AS group_frequency,
		ROUND (MIN (c2.sku_discount / c2.sku_sum * 100), 2) AS group_min_discount
	FROM cards c 
		JOIN transactions t ON c.customer_card_id = t.customer_card_id 
		JOIN checks c2 ON t.transaction_id = c2.transaction_id 
		JOIN product_grid pg ON c2.sku_id = pg.sku_id 
		JOIN purchases_periods ON c.customer_id = purchases_periods.customer_id
	GROUP BY c.customer_id , pg.group_id, purchase_period 
	ORDER BY c.customer_id , pg.group_id ;

