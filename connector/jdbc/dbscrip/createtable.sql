CREATE TABLE football_players (
  name VARCHAR ( 50 ) PRIMARY KEY,
  nationality VARCHAR ( 255 ) NOT NULL,
  is_retired BOOLEAN DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  modified_at TIMESTAMP
  );

alter system set wal_level to 'logical';


CREATE OR REPLACE FUNCTION change_modified_at()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
    NEW.modified_at := NOW();
    RETURN NEW;
END;
$$
;
CREATE TRIGGER modified_at_updates
  BEFORE UPDATE
  ON football_players
  FOR EACH ROW
  EXECUTE PROCEDURE change_modified_at();


CREATE DATABASE customers;

CREATE TABLE customers (id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name text);
ALTER TABLE customers REPLICA IDENTITY USING INDEX customers_pkey;
INSERT INTO customers (name) VALUES ('joe'), ('bob'), ('sue');
