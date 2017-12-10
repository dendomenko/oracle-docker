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
	group_id number(10) DEFAULT NULL
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


------------------------------------------------
CREATE TABLE client (
	id number(10) PRIMARY KEY,
	name varchar2(50) NOT NULL,
	surname varchar2(50) NOT NULL,
	total_sum number(10) DEFAULT 0,
	discount number(3) DEFAULT 5
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

----------------------------------------------
CREATE TABLE orders (
	id number(10) PRIMARY KEY,
	client_id number(10) DEFAULT NULL,
    drug_id number(10) DEFAULT NULL,
    created_at date
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
    ADD CONSTRAINT fk_order_user FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE SET NULL;

ALTER TABLE orders 
    ADD CONSTRAINT fk_order_drug FOREIGN KEY (drug_id) REFERENCES drug(id) ON DELETE SET NULL;



-----------------------------------------------------------
-- delete tables
DROP TABLE orders;
DROP TABLE client;
DROP TABLE drug;
DROP TABLE drug_group;
DROP TABLE drugstore;