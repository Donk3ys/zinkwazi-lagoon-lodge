DROP TABLE items;

CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    subheading VARCHAR(60),
    type INT NOT NULL,
    price INT NOT NULL,
    description TEXT,
    active BOOL NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT now()
);

-- Breakfast id: 1 -> 9
insert into items (name, subheading, type, price, description, active, updated_At)
	values ('Models Breakfast', '(Martini Style)', 1, 5500, 'Layered muesli with plain yoghurt with fresh fruit.', TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Up & Adim', 1, 5000, '2 Eggs, 2 rashers of bacon, fried tomato and toast.', TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Hangover Cure', 1, 7500, '2 Eggs, 2 rashers of bacon, choice of beef or pork sausage, fried tomato, spicy baked beans and toast.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Omelette', 'Choice of 3 fillings' , 1, 7000, 'Ham / Tomato / Peppers / Cheese / Mushroom / Spring onion/ Jelapino /Pineapple / Bacon/ Spinach.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Bacon', 1, 7400, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with bacon.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Ham', 1, 7000, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with ham.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Spinach & Mushroom', 1, 6400, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with spinach & mushroom.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Eggs Ben', 'Smoked Salmon', 1, 7800, '2 poached eggs with an English muffin smothered in hollandaise sauce. Topped with smoked salmon.', TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('French Toast', 1, 5200, 'Cinnamon egg fried bread served with bacon & maple syrup.', TRUE, '2020-07-21 00:00:00');

-- Chefs Choice id: 10 -> 14
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Hake & Prawn', 'Combo', 2, 18500, 'Grilled or Battered hake served with chips or savory rice(choice of tartare/ lemon/ periperi)', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, description, active, updated_at)
	values ('Rump & Ribs', 'Combo', 2, 16000, '200g Rump and 200g Ribs served with chips and onion rings.', TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, active, updated_at)
	values ('Chicken & Mushroom', 'Pasta', 2, 12500, TRUE, '2020-07-21 00:00:00');
insert into items (name, subheading, type, price, active, updated_at)
	values ('Chicken & Prawn', 'Pasta', 2, 14500, TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, description, active, updated_at)
	values ('Line Fish', 2, 16000, 'Grilled line fish topped with (lemon butter or peri-peri sauce) and served with chips or savory rice.', TRUE, '2020-07-21 00:00:00');

-- Salad id: 15 -> 19
insert into items (name, type, price, active, updated_at) values ('Greek', 3, 6900, TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Chicken Cesar', 3, 8500, TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Avo Bacon Feta', 3, 8900, TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Morrocan Steak', 3, 7900, TRUE, '2020-07-21 00:00:00');
insert into items (name, type, price, active, updated_at) values ('Beet & Butternut', 3, 6900, TRUE, '2020-07-21 00:00:00');


----------------------
DROP TABLE item_options;

CREATE TABLE item_options (
    id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    type VARCHAR(40) NOT NULL,
    name VARCHAR(60) NOT NULL
);

insert into item_options (item_id, type, name) values (2, 'Bread', 'White');
insert into item_options (item_id, type, name) values (2, 'Bread', 'Brown');
insert into item_options (item_id, type, name) values (2, 'Bread', 'Rye');
insert into item_options (item_id, type, name) values (2, 'Egg', 'Soft');
insert into item_options (item_id, type, name) values (2, 'Egg', 'Hard');

insert into item_options (item_id, type, name) values (3, 'Bread', 'White');
insert into item_options (item_id, type, name) values (3, 'Bread', 'Brown');
insert into item_options (item_id, type, name) values (3, 'Bread', 'Rye');
insert into item_options (item_id, type, name) values (3, 'Egg', 'Soft');
insert into item_options (item_id, type, name) values (3, 'Egg', 'Hard');

insert into item_options (item_id, type, name) values (4, 'Filling 3', 'None');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Bacon');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Cheese');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Ham');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Jelapino');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Mushrooms');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Peppers');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Pineapple');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Spinach');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Spring Onions');
insert into item_options (item_id, type, name) values (4, 'Filling 3', 'Tomatos');

insert into item_options (item_id, type, name) values (4, 'Filling 2', 'None');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Bacon');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Cheese');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Ham');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Jelapino');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Mushrooms');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Peppers');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Pineapple');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Spinach');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Spring Onions');
insert into item_options (item_id, type, name) values (4, 'Filling 2', 'Tomatos');

insert into item_options (item_id, type, name) values (4, 'Filling 1', 'None');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Bacon');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Cheese');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Ham');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Jelapino');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Mushrooms');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Peppers');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Pineapple');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Spinach');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Spring Onions');
insert into item_options (item_id, type, name) values (4, 'Filling 1', 'Tomatos');

------------
DROP TABLE item_option_to_order_item_links;

CREATE TABLE item_option_to_order_item_links (
    order_item_link_id BIGINT NOT NULL,
    item_option_id INT NOT NULL
);


-----------------------
DROP TABLE types;

CREATE TABLE types (
    id SERIAL PRIMARY KEY,
    type VARCHAR(40) NOT NULL
);

insert into types (type) values ('Breakfast');
insert into types (type) values ('Chefs Choice');
insert into types (type) values ('Salad');
----------------


DROP TABLE orders;

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    payment_id VARCHAR(40) NOT NULL,
    number INT NOT NULL,
    price INT NOT NULL,
    created_at TIMESTAMP,
    prepared BOOL DEFAULT false,
    prepared_at TIMESTAMP,
    delivered BOOL DEFAULT false,
    delivered_at TIMESTAMP
);


-------------------------
DROP TABLE order_item_links;

CREATE TABLE order_item_links (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    item_id INT NOT NULL
);


-------------------------
DROP TABLE users;

CREATE TABLE users (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100),
  password TEXT NOT NULL,
	role VARCHAR(15),
	active BOOL DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP, 
  updated_at TIMESTAMP
);

-- roles: super , admin, kitchen

INSERT INTO "users" (username, email, password, role, active, updated_at, created_at)
	VALUES ('super', 'super@e.com', '$2y$12$XErRNITbgV.ngUoGBwYRzOPn07cNI6XBx7Mn9wz7YNoiVPffs.iHq',
			'super', TRUE, '2020-10-02T09:00:00.000Z', '2020-10-02T09:00:00.000Z'
);
INSERT INTO "users" (username, email, password, role, active, updated_at, created_at)
	VALUES ('admin', 'admin@e.com', '$2y$12$XErRNITbgV.ngUoGBwYRzOPn07cNI6XBx7Mn9wz7YNoiVPffs.iHq',
			'admin', TRUE, '2020-10-02T09:00:00.000Z', '2020-10-02T09:00:00.000Z'
);
INSERT INTO "users" (username, email, password, role, active, updated_at, created_at)
	VALUES ('kitchen', 'admin@e.com', '$2y$12$XErRNITbgV.ngUoGBwYRzOPn07cNI6XBx7Mn9wz7YNoiVPffs.iHq',
			'kitchen', TRUE, '2020-10-02T09:00:00.000Z', '2020-10-02T09:00:00.000Z'
);
