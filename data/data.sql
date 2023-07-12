call import_data('personal_information', '''/home/denmiagkov/Programming/SQL/test/mock_data_personal_information.csv''');
call import_data('product_grid', '''/home/denmiagkov/Programming/SQL/test/mock_data_product_grid.csv''');

insert into sku_group
values
(1, 'vegetables'),
(2, 'fruits'),
(3, 'grains'),
(4, 'dairy'),
(5, 'fish'),
(6, 'poultry'),
(7, 'meat'),
(8, 'baking'),
(9, 'candies'),
(10, 'non-alcoholic beverages'),
(11, 'alcoholic beverages'),
(12, 'household chemical goods'),
(13, 'others');

insert into cards 
values (default, 11),(default, 5),(default, 3),(default, 6),(default, 10),(default, 7),(default, 14),
(default, 13), (default, 8),(default, 2),(default, 12),(default, 5),(default, 1),(default, 9),(default, 4),
(default, 3),(default, 8), (default, 5),(default, 7),(default, 11),(default, 7),(default, 14),(default, 10),
(default, 2),(default, 6),(default, 15), (default, 9),(default, 4),(default, 12),(default, 3);

insert into stores
values
(1, 'Brateevskaya, 25'),
(2, 'Klyuchavaya, 6/1'),
(3, 'Alma-Atinskaya, 8'),
(4, 'Borisovskie Prudy, 8a');

call fill_checks(5, 8);
call fill_transactions();

create procedure fill_checks (number_of_transactions int, max_number_of_goods int) as $$
declare
	this_trans_id int := (select (coalesce ((select max(transaction_id) from transactions), 0)+1));
	number_of_transactions int := number_of_transactions + this_trans_id;
	this_sku_id int;
	assortiment int;
	this_sku_amount numeric;
	this_sku_sum numeric;
	this_sku_sum_paid numeric;
	this_sku_discount numeric;
begin
	while this_trans_id < number_of_transactions  loop
		insert into transactions (transaction_id) values(this_trans_id);
		assortiment = floor(random()*max_number_of_goods)+1;
		while assortiment>0 loop
			this_sku_id = floor(random()*100)+1;
			this_sku_amount = floor(random()*3)+1;
			this_sku_sum = this_sku_amount * (select sku_retail_price from product_grid where this_sku_id = 
									product_grid.sku_id);
			this_sku_discount = random()*0.3 * this_sku_sum;
			insert into checks values(this_trans_id, this_sku_id, this_sku_amount, this_sku_sum, 
			(this_sku_sum-this_sku_discount), this_sku_discount);
			assortiment := assortiment - 1;
		end loop;
		this_trans_id := this_trans_id + 1;		
	end loop;
end $$ language plpgsql;

create or replace procedure fill_transactions() as $$
declare 
	n int = (select count(*) from transactions) + 1;
	i int = min (transaction_id) from transactions where transaction_sum IS null;
	this_id int;
	this_card_id int;
	this_sum numeric;
	this_datetime timestamp = coalesce ((select max(transaction_datetime) from transactions), 
'2023-06-01T00:00:00.000Z')+ interval '1 day';
	this_store_id int;
begin
	while i < n loop
		this_id = i;
		this_card_id = floor(random()*(select count(*) from cards))+1;
		this_sum = (select sum(sku_sum_paid) from checks where this_id=checks.transaction_id);
		this_datetime = this_datetime + interval '1 hour';
		this_store_id = floor(random()*(select count(*) from stores))+1;
		update transactions set (customer_card_id, transaction_sum, transaction_datetime, transaction_store_id)
		= (this_card_id, this_sum, this_datetime, this_store_id) 
		where transactions.transaction_id = this_id;
		i = i +1;		
	end loop;
end $$ language plpgsql;


