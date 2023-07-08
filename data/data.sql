call export_data('personal_information', '''/home/denmiagkov/Programming/SQL/test/mock_data_personal_information.csv''');
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
values (default, 11),(default, 16),(default, 3),(default, 16),(default, 10),(default, 7),(default, 14),
(default, 13), (default, 8),(default, 2),(default, 12),(default, 5),(default, 1),(default, 9),(default, 20),
(default, 17),(default, 8), (default, 5),(default, 7),(default, 11),(default, 7),(default, 14),(default, 10),
(default, 19),(default, 6),(default, 15), (default, 9),(default, 4),(default, 12),(default, 3);

insert into stores
values
(1, 'Brateevskaya, 25'),
(2, 'Klyuchavaya, 6/1'),
(3, 'Alma-Atinskaya, 8'),
(4, 'Borisovskie Prudy, 8a');
