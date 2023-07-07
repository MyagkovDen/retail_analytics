create table personal_information3
(
	customer_id SERIAL primary key,
	customer_name VARCHAR(25)check(substring(customer_name, 1, 1) = upper(substring(customer_name, 1, 1))),
	customer_surname VARCHAR(25)check(substring(customer_surname, 1, 1) = upper(substring(customer_surname, 1, 1))),
	customer_primary_email VARCHAR(25) check (customer_primary_email like '%@%'),
	customer_primary_phone VARCHAR(12) check (customer_primary_phone like '+7__________')
);

