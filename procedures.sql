
----------------------------- INSERTING PROCEDURES --------------------------------
CREATE OR REPLACE PROCEDURE add_store (name varchar2, city varchar2, address varchar2) AS
BEGIN
	INSERT INTO drugstore (name, city, address) VALUES (name, city, address);
	commit;
END add_store;
/

CREATE OR REPLACE PROCEDURE add_drug_group (name varchar2) AS
BEGIN
	INSERT INTO drug_group (name) VALUES (name);
	commit;
END add_drug_group;
/

CREATE OR REPLACE PROCEDURE add_drug (pname varchar2, pprice number, pquantity number, pgroup varchar2) AS
g_id number(10);
CURSOR c1 IS SELECT id FROM drug_group WHERE name = pgroup;
BEGIN
  open c1;
  fetch c1 into g_id;
  close c1;
INSERT INTO drug (name, price, quantity, group_id) VALUES (pname, pprice, pquantity, g_id);
commit;
END add_drug;
/

CREATE OR REPLACE PROCEDURE add_client (name varchar2, surname varchar2) AS
BEGIN
	INSERT INTO client (name, surname) VALUES (name, surname);
  commit;
END add_client;
/

CREATE OR REPLACE PROCEDURE add_order (name varchar2, surname varchar2, drug varchar2) AS
u_id number(10);
d_id number(10);
price number(10);
CURSOR get_uid IS SELECT id FROM client WHERE name = name AND surname = surname;
CURSOR get_drug_id IS SELECT id FROM drug WHERE name = drug;
CURSOR get_price IS SELECT price FROM drug WHERE name = drug;
BEGIN
 open get_uid;
  fetch get_uid into u_id;
  close get_uid;
   open get_drug_id;
  fetch get_drug_id into d_id;
  close get_drug_id;
   open get_price;
  fetch get_price into price;
  close get_price;
	INSERT INTO orders (client_id, drug_id, created_at) VALUES (u_id, d_id, sysdate);
	UPDATE drug d1 SET d1.quantity = (d1.quantity - 1) WHERE d1.id = d_id;
	UPDATE client c1 SET c1.total_sum = (c1.total_sum + price) WHERE c1.id = u_id;
	commit;
END add_order;
/

CREATE OR REPLACE PROCEDURE add_order_by_user_id (uid number, did number) AS
BEGIN
	INSERT INTO orders (client_id, drug_id, created_at) VALUES (uid, did, sysdate);
  commit;
END add_order_by_user_id;
/


-- DESTROY PROCEDURES

CREATE OR REPLACE PROCEDURE delete_client (name varchar2, surname varchar2) AS
BEGIN
  DELETE FROM orders WHERE name = name AND surname = surname;
  commit;
END delete_client;
/

-- CALCULATION PROCEDURES

CREATE OR REPLACE PROCEDURE calculate_discount (name varchar2, surname varchar2) AS
total number(10);
u_id number(10);
CURSOR get_total IS SELECT total_sum FROM client WHERE name = name AND surname = surname;
CURSOR get_id IS SELECT id FROM client WHERE name = name AND surname = surname;
BEGIN
  open get_total;
  fetch get_total into total;
  close get_total;
  open get_id;
  fetch get_id into u_id;
  close get_id;
  IF total > 0 AND total < 100 THEN
      UPDATE client c1 SET c1.discount = 7 WHERE c1.id = u_id;         
    ELSIF total >= 100 AND total < 500 THEN 
      UPDATE client c1 SET c1.discount = 10 WHERE c1.id = u_id;      
    ELSE 
      UPDATE client c1 SET c1.discount = 15 WHERE c1.id = u_id;   
    END IF;
    commit;
END calculate_discount;
/


-- SELECT PROCEDURES

CREATE OR REPLACE PROCEDURE find_drug (aname varchar2) AS
fname varchar2(50);
fquantity number(10);
fprice number(10);
CURSOR find IS SELECT name, quantity, price FROM drug WHERE name LIKE '%'||aname||'%';
BEGIN
  OPEN find;
   LOOP
      FETCH find INTO fname, fquantity, fprice;
      EXIT WHEN find%NOTFOUND;
      dbms_output.put_line('name: ' || fname || ', qty: ' || fquantity || ', price:' || fprice);
   END LOOP;
   CLOSE find;
END find_drug;
/