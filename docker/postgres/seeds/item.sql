-- run /i <path to file>

DROP TABLE items;

CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    subheading VARCHAR(60),
    type INT NOT NULL,
    price INT NOT NULL,
    description TEXT,
    active BOOL NOT NULL DEFAULT false,
    updated_at TIMESTAMP DEFAULT now()
);

-- Breakfast
insert into items (name, subheading, type, price, description, active, updated_At)
	values ('Models Breakfast', '(Martini Style)', 1, 5500, 'Layered muesli with plain yoghurt with fresh fruit.', true, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Up & Adim', 1, 5000, '2 Eggs, 2 rashers of bacon, fried tomato and toast.', true, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Hangover Cure', 1, 7500, '2 Eggs, 2 rashers of bacon, choice of beef or pork sausage, fried tomato, spicy baked beans and toast.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Omelette', 'Choice of 3 fillings' , 1, 7000, 'Ham / Tomato / Peppers / Cheese / Mushroom / Spring onion/ Jelapino /Pineapple / Bacon/ Spinach.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Bacon', 1, 7400, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with bacon.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Ham', 1, 7000, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with ham.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Spinach & Mushroom', 1, 6400, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with spinach & mushroom.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Smoked Salmon', 1, 7800, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with smoked salmon.', true, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('French Toast', 1, 5200, 'Cinnamon egg fried bread served with bacon & maple syrup.', true, '2020-07-21 00:00:00');


-- Chefs Choice
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Hake & Prawn', 'Combo', 2, 18500, 'Grilled or Battered hake served with chips or savory rice(choice of tartare/ lemon/ periperi)', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Rump & Ribs', 'Combo', 2, 16000, '200g Rump and 200g Ribs served with chips and onion rings.', true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, active, updated_at)
	values ('Chicken & Mushroom', 'Pasta', 2, 12500, true, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, active, updated_at)
	values ('Chicken & Prawn', 'Pasta', 2, 14500, true, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Line Fish', 2, 16000, 'Grilled line fish topped with (lemon butter or peri-peri sauce) and served with chips or savory rice.', true, '2020-07-21 00:00:00');


-- Salad
insert into items (name, type, price, active, updated_at) values ('Greek', 3, 6900, true, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Chicken Cesar', 3, 8500, true, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Avo Bacon Feta', 3, 8900, true, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Morrocan Steak', 3, 7900, true, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Beet & Butternut', 3, 6900, true, '2020-07-21 00:00:00');
