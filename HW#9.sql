-- Задание 1.1 --
start transaction;

	use shop;
	drop view if exists v1;
	create view v1 as 
	select * from users where id = 1;
	
	select id into @id from users where id = 1;
	select name into @name from users where id = 1;
	select birthday_at into @birthday from users where id = 1;
	select created_at into @created from users where id = 1;
	select updated_at into @updated from users where id = 1;

	insert into sample.users values (@id, @name, @birthday, @created, @updated);
	select * from sample.users;
	
commit; 

-- Задание 1.2 -- 
drop view if exists v2;
create view v2 as
	select 
		p.name as Product_name, 
		c.name as Catalog_name
	from 
		products as p
	join
		catalogs as c
	on
		p.catalog_id = c.id;

select * from v2;

-- Задание 1.3 --
TRUNCATE orders;
insert into orders values 
	(NULL, 1, '2018-08-01', DEFAULT),
	(NULL, 2, '2016-08-04', DEFAULT),
	(NULL, 3, '2018-08-16', DEFAULT),
	(NULL, 4, '2018-08-17', DEFAULT);

DROP TEMPORARY TABLE IF EXISTS temp;
CREATE TEMPORARY TABLE temp (days DATE, flag BIT DEFAULT 0);

DROP PROCEDURE IF EXISTS august_days;
DELIMITER //
CREATE PROCEDURE august_days()
BEGIN
	DECLARE j DATE;
	declare inc INT default  (select count(*) from orders);

	set j = '2018-08-01';	

	first: WHILE day(j) < 32 DO
		insert into temp(days) values (j);
		second: while inc >= 1 do
			if (date_format(j, '%m-%d')) = date_format((select created_at from orders where id = inc), '%m-%d')
			then update temp set flag = 1;
			end if;
			set inc = inc -1;
		end while second;
		set j = j + interval 1 day;
	end while first;
END//

DELIMITER ;

CALL august_days();

SELECT * FROM temp;



-- Задание 3.1 --
USE shop;

DROP USER IF EXISTS shop_read;
CREATE USER shop_read;

DROP USER IF EXISTS all_in;
CREATE USER all_in;

GRANT SELECT ON *.* TO shop_read;
GRANT ALL ON shop.* TO all_in;
GRANT GRANT OPTION ON shop.* TO all_in;

-- Задание 3.2 --
DROP TRIGGER IF EXISTS check_products_insert;
DROP TRIGGER IF EXISTS check_products_update;

DELIMITER //

CREATE TRIGGER check_products_insert
BEFORE INSERT ON products
FOR EACH ROW BEGIN
	IF NEW.description IS NULL AND NEW.name IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Canceled operation!The fields are NULL';
	END IF;
END//

CREATE TRIGGER check_products_update
BEFORE UPDATE ON products
FOR EACH ROW BEGIN
	IF (NEW.description IS NULL AND OLD.name IS NULL) 
	OR (OLD.description IS NULL AND NEW.name IS NULL) 
	OR (NEW.description IS NULL AND NEW.name IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Canceled operation!The fields are NULL';
	END IF;
END//

DELIMITER ;

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  (NULL, 'For PC, establish on Intel.', 78290.00, 1),
  ('Intel Core i5-7400', NULL, 127300.00, 1);
INSERT INTO products
  (name, description, price, catalog_id)
VALUES (NULL, NULL, 47780.00, 1);

UPDATE products SET name = NULL, description = NULL WHERE id = 1;
UPDATE products SET name = NULL WHERE id = 1;
UPDATE products SET description = NULL WHERE id = 2;

SELECT * FROM products;
































	















