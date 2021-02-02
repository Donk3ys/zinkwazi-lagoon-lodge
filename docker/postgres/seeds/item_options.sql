DROP TABLE item_options;

CREATE TABLE item_options (
    id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    type VARCHAR(40) NOT NULL,
    name VARCHAR(60) NOT NULL
);


insert into item_options (item_id, type, name) values (1, 'Bread', 'White');
insert into item_options (item_id, type, name) values (1, 'Bread', 'Brown');

insert into item_options (item_id, type, name) values (5, 'Bread', 'White');
insert into item_options (item_id, type, name) values (5, 'Bread', 'Brown');
