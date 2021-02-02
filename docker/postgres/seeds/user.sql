DROP TABLE users;

CREATE TABLE users (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  username varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  password TEXT NOT NULL,
  created_at DATE,
  updated_at DATE
);
