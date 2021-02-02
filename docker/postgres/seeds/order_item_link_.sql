DROP TABLE order_item_links;

CREATE TABLE order_item_links (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    item_id INT NOT NULL
);
