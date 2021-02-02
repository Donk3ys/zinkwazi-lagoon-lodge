DROP TABLE types;

CREATE TABLE types (
    id SERIAL PRIMARY KEY,
    type VARCHAR(40) NOT NULL
);

insert into types (type) values ('Breakfast');
insert into types (type) values ('Chefs Choice');
insert into types (type) values ('Salad');
