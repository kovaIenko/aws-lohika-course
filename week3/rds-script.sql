--create database aws;

CREATE TABLE items(
   id serial  PRIMARY KEY,
   title VARCHAR (100) NOT NULL,
   category VARCHAR (50) NOT NULL,
   barcode VARCHAR(20),
   store_id VARCHAR (100) NOT NULL
);


INSERT INTO  items (id, title, category, barcode, store_id)
VALUES (1, 'Finlandia 1l', 'VODKA', '42345678765432', 'AUCHAN');

INSERT INTO  items (id, title, category, barcode, store_id)
VALUES (2, 'Brandy 0.5l', 'BRANDY', '75477447474774', 'NOVUS');


select * from items; 

