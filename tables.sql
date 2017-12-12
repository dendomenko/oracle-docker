--LINKS

CREATE DATABASE LINK winlink
CONNECT TO gr156
IDENTIFIED BY gr156
USING 'k105win';

CREATE DATABASE LINK winlink
CONNECT TO drugstore_win
IDENTIFIED BY "123456"
USING 'localhost:1521/xe';


-- create tables and sequense with triggers for autoincremental logic
---------------------------------------------
CREATE TABLE drugstore (
	id number(10) PRIMARY KEY,
    name varchar2(50) NOT NULL,
    city varchar2(50) NOT NULL,
    address varchar2(50) NOT NULL
);
create sequence drugstore_id_seq;
create trigger drugstore_ai
	before insert on drugstore
	for each row
begin
	select drugstore_id_seq.nextval
	into :new.id
	from dual;
end;
/


-- group for drug
--------------------------------------------
CREATE TABLE  drug_group (
	id number(10) PRIMARY KEY,
    name varchar2(50) NOT NULL
);
create sequence drug_group_id_seq;
create trigger drug_group_ai
	before insert on drug_group
	for each row
begin
	select drug_group_id_seq.nextval
	into :new.id
	from dual;
end;
/

-------------------------------------------
CREATE TABLE drug (
	id number(10) PRIMARY KEY,
	name varchar2(50) NOT NULL,
	price number(10) NOT NULL,
	quantity number(10) DEFAULT 0,
	group_id number(10) DEFAULT NULL,
	flag varchar2(1) DEFAULT NULL
);
create sequence drug_id_seq;
create trigger drug_ai
	before insert on drug
	for each row
begin
	select drug_id_seq.nextval
	into :new.id
	from dual;
end;
/
ALTER TABLE drug
ADD CONSTRAINT fk_drug_group FOREIGN KEY (group_id) REFERENCES drug_group(id) ON DELETE SET NULL;

CREATE OR REPLACE TRIGGER drug_ins
AFTER INSERT ON drug 
FOR EACH ROW
WHEN (new.flag is null)
BEGIN
    INSERT INTO drug@winlink VALUES(:new.id, :new.name, :new.price, :new.quantity, :new.group_id, 'T');
END;
/

CREATE OR REPLACE TRIGGER drug_del
 AFTER DELETE ON drug
FOR EACH ROW
  DECLARE
    Mutating EXCEPTION;
    PRAGMA exception_init (mutating, -4091);
    BEGIN
        DELETE drug@winlink
           WHERE id=:old.id;
        EXCEPTION WHEN mutating THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER drug_upd
   AFTER UPDATE ON drug
FOR EACH ROW
      BEGIN		
        IF NOT updating('flag') THEN
          UPDATE drug@winlink SET
             id=:new.id,
             name=:new.name,
             price=:new.price,
             quantity=:new.quantity,
             group_id=:new.group_id,
             flag='T'
          WHERE id=:old.id;
        END IF;
END;
/
------------------------------------------------
CREATE TABLE client (
	id number(10) PRIMARY KEY,
	name varchar2(50) NOT NULL,
	surname varchar2(50) NOT NULL,
	total_sum number(10) DEFAULT 0,
	discount number(3) DEFAULT 5,
	flag varchar2(1) DEFAULT NULL
);
create sequence client_id_seq;
create trigger client_ai
	before insert on client
	for each row
begin
	select client_id_seq.nextval
	into :new.id
	from dual;
end;
/

CREATE OR REPLACE TRIGGER client_ins
AFTER INSERT ON client
FOR EACH ROW
WHEN (new.flag is null)
     BEGIN
        INSERT INTO client@winlink  VALUES(:new.id, :new.name, :new.surname, :new.total_sum, :new.discount, 'T');
END;
/

CREATE OR REPLACE TRIGGER client_del
	AFTER DELETE ON client
FOR EACH ROW
  DECLARE
  	Mutating EXCEPTION;
	PRAGMA exception_init (mutating, -4091);
	  BEGIN		
	 	DELETE client@winlink
			WHERE id=:old.id;
		EXCEPTION WHEN mutating THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER client_upd
	AFTER UPDATE ON client
FOR EACH ROW
	  BEGIN		
		IF NOT updating('flag') THEN
		   UPDATE client@winlink  SET
		   	 id=:new.id,
			 name=:new.name,
			 surname=:new.surname,
			 total_sum=:new.total_sum,
			 discount=:new.discount,
			 flag='T'
		  WHERE id=:old.id;
		END IF;
END;
/
----------------------------------------------
CREATE TABLE orders (
	id number(10) PRIMARY KEY,
	client_id number(10) NOT NULL,
    drug_id number(10) NOT NULL,
    drugstore_id number(10) NOT NULL,
    created_at date,
    flag varchar2(1) DEFAULT NULL
);
create sequence orders_id_seq;
create trigger orders_ai
	before insert on orders
	for each row
begin
	select orders_id_seq.nextval
	into :new.id
	from dual;
end;
/
ALTER TABLE orders 
    ADD CONSTRAINT fk_order_user FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE CASCADE;

ALTER TABLE orders 
    ADD CONSTRAINT fk_order_drug FOREIGN KEY (drug_id) REFERENCES drug(id) ON DELETE CASCADE;

ALTER TABLE orders 
    ADD CONSTRAINT fk_order_drugstore FOREIGN KEY (drugstore_id) REFERENCES drugstore(id) ON DELETE CASCADE;

CREATE OR REPLACE TRIGGER orders_ins
	AFTER INSERT ON orders
FOR EACH ROW
WHEN (new.flag is null)
	  BEGIN		
	 	INSERT INTO orders@winlink  VALUES(:new.id, :new.client_id, :new.drug_id, :new.drugstore_id, :new.created_at, 'T');
END;
/

CREATE OR REPLACE TRIGGER orders_del
	AFTER DELETE ON orders
FOR EACH ROW
  DECLARE
  	Mutating EXCEPTION;
	PRAGMA exception_init (mutating, -4091);
	  BEGIN		
	 	DELETE orders@winlink
			WHERE id=:old.id;
		EXCEPTION WHEN mutating THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER orders_upd
	AFTER UPDATE ON orders
FOR EACH ROW
	  BEGIN		
		IF NOT updating('flag') THEN
		   UPDATE orders@winlink  SET
		   	 id=:new.id,
			 client_id=:new.client_id,
			 drug_id=:new.drug_id,
			 drugstore_id=:new.drugstore_id,
			 created_at=:new.created_at,
			 flag='T'
		  WHERE id=:old.id;
		END IF;
END;
/
-----------------------------------------------------------
-- delete tables
DROP TABLE orders;
DROP TABLE client;
DROP TABLE drug;
DROP TABLE drug_group;
DROP TABLE drugstore;
---------------------------
DROP trigger orders_ai;
DROP trigger client_ai;
DROP trigger drug_ai;
DROP trigger drug_group_ai;
DROP trigger drugstore_ai;

DROP trigger orders_ins;
DROP trigger client_ins;
DROP trigger drug_ins;
DROP trigger orders_del;
DROP trigger client_del;
DROP trigger drug_del;
DROP trigger orders_upd;
DROP trigger client_upd;
DROP trigger drug_upd;
------------------------------------
DROP sequence orders_id_seq;
DROP sequence client_id_seq;
DROP sequence drug_id_seq;
DROP sequence drug_group_id_seq;
DROP sequence drugstore_id_seq;

DROP DATABASE LINK winlink;