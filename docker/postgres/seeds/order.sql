DROP TABLE orders;

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    payment_id VARCHAR(40) NOT NULL,
    number INT NOT NULL,
    price INT NOT NULL,
    created_at TIMESTAMP DEFAULT now(), 
    prepared BOOL DEFAULT false,
    prepared_at TIMESTAMP, 
    delivered BOOL DEFAULT false,
    delivered_at TIMESTAMP 
);

--insert into types (type) values ('Breakfast');
