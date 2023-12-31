create table personal_information
(
	customer_id SERIAL primary key,
	customer_name VARCHAR(25)check(substring(customer_name, 1, 1) = upper(substring(customer_name, 1, 1))),
	customer_surname VARCHAR(25)check(substring(customer_surname, 1, 1) = upper(substring(customer_surname, 1, 1))),
	customer_primary_email VARCHAR(45) check (customer_primary_email like '%@%'),
	customer_primary_phone VARCHAR(12) check (customer_primary_phone like '+7__________')
);

create table cards
(
	customer_card_id serial primary key,
	customer_id INT,
	foreign key (customer_id) references personal_information(customer_id)
);

create table sku_group
(
	group_id varchar(20) primary key,
	group_name varchar(45)
);

create table product_grid
(
	sku_id int(20) primary key,
	sku_name varchar(45),
	group_id varchar(20) references sku_group(group_id),
	sku_purchase_price numeric(9,2),
	sku_retail_price numeric(9,2),
);

create table stores
(
	transaction_store_id int primary key,
	store_address varchar(45),
);

create table transactions
(
	transaction_id serial primary key,
	customer_card_id int references cards(customer_card_id),
	transaction_sum numeric(9,2),
	transaction_datetime timestamp,
	transaction_store_id int references stores(transaction_store_id)	
);

create table checks
(
	transaction_id int references transactions(transaction_id),
	sku_id int(20) references product_grid(sku_id),
	sku_amount numeric(9,2),
	sku_sum numeric(9,2),
	sku_sum_paid numeric(9,2),
	sku_discount numeric(9,2)	
);

create table date_of_analysis_formation
(
	analysis_formation timestamp
);

create procedure import_data (table_name varchar, file_path varchar) as $$
declare 
	tbl varchar := 'copy ' || table_name || ' from ' || file_path || ' delimiter '','' csv header';
begin
	execute tbl;
end;
$$ language plpgsql;

create procedure export_data (table_name varchar, file_path varchar) as $$
declare 
	tbl varchar := 'copy ' || table_name || ' to ' || file_path || ' delimiter '','' csv header';
begin
	execute tbl;
end;
$$ language plpgsql;


