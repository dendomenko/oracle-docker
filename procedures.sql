
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

CREATE OR REPLACE PROCEDURE add_order (iname varchar2, isurname varchar2, idrug varchar2, drugstore_id number) AS
u_id number(10);
d_id number(10);
price number(10);
CURSOR get_uid IS SELECT id FROM client WHERE name = iname AND surname = isurname;
CURSOR get_drug_id IS SELECT id FROM drug WHERE name = idrug;
CURSOR get_price IS SELECT price FROM drug WHERE name = idrug;
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
	INSERT INTO orders (client_id, drug_id, created_at, drugstore_id) VALUES (u_id, d_id, sysdate, drugstore_id);
	UPDATE drug d1 SET d1.quantity = (d1.quantity - 1) WHERE d1.id = d_id;
	UPDATE client c1 SET c1.total_sum = (c1.total_sum + price) WHERE c1.id = u_id;
	commit;
END add_order;
/

CREATE OR REPLACE PROCEDURE add_order_by_user_id (uid number, did number, dsid number) AS
BEGIN
	INSERT INTO orders (client_id, drug_id, created_at, drugstore_id) VALUES (uid, did, sysdate, dsid);
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

CREATE OR REPLACE PROCEDURE delete_drugstore (id number) AS
BEGIN
  DELETE FROM drugstore WHERE id =id;
  commit;
END delete_drugstore;
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


CREATE OR REPLACE PROCEDURE calculate AS
total number(10);
u_id number(10);
CURSOR get_total IS SELECT id, total_sum FROM client;
BEGIN
  open get_total;
    LOOP
    fetch get_total into u_id, total;
      EXIT WHEN get_total%NOTFOUND;
        IF total = 0 THEN
          UPDATE client c1 SET c1.discount = 0 WHERE c1.id = u_id;       
        ELSIF total > 0 AND total < 100 THEN
          UPDATE client c1 SET c1.discount = 7 WHERE c1.id = u_id;         
        ELSIF total >= 100 AND total < 500 THEN 
          UPDATE client c1 SET c1.discount = 10 WHERE c1.id = u_id;      
        ELSE 
          UPDATE client c1 SET c1.discount = 15 WHERE c1.id = u_id;   
        END IF;
      END LOOP;
      close get_total;
    commit;
END calculate;
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

CREATE OR REPLACE PROCEDURE find_client(aname varchar2, asurname varchar2) AS
fname varchar2(50);
fsurname varchar2(50);
fdiscount number(10);
CURSOR find IS SELECT name, surname, discount FROM client WHERE name LIKE '%'||aname||'%' AND surname LIKE '%'||asurname||'%';
BEGIN
  OPEN find;
   LOOP
      FETCH find INTO fname, fsurname, fdiscount;
      EXIT WHEN find%NOTFOUND;
      dbms_output.put_line('name: ' || fname || ', surname: ' || fsurname || ', discount:' || fdiscount);
   END LOOP;
   CLOSE find;
END find_client;
/

CREATE OR REPLACE PROCEDURE show_drug AS
fname varchar2(50);
fquantity number(10);
fprice number(10);
fgname varchar2(50);
CURSOR find IS SELECT d.name, d.quantity, d.price, dg.name FROM drug d INNER JOIN drug_group dg on d.group_id=dg.id;
BEGIN
  OPEN find;
   LOOP
      FETCH find INTO fname, fquantity, fprice, fgname;
      EXIT WHEN find%NOTFOUND;
      dbms_output.put_line('name: ' || fname || ', qty: ' || fquantity || ', group:' || fgname || ', price:' || fprice);
   END LOOP;
   CLOSE find;
END show_drug;
/

CREATE OR REPLACE PROCEDURE show_order AS
ffirst_name varchar2(50);
flast_name varchar2(50);
fprice number(10);
fname varchar2(50);
fdrugstore varchar2(50);
faddress varchar2(50);
CURSOR find IS SELECT c.name, c.surname, d.name, d.price, ds.name, ds.address FROM orders o INNER JOIN client c ON o.client_id = c.id 
    INNER JOIN drug d ON o.drug_id = d.id INNER JOIN drugstore ds ON o.drugstore_id = ds.id;
BEGIN
  OPEN find;
   LOOP
      FETCH find INTO ffirst_name, flast_name, fname, fprice, fdrugstore, faddress;
      EXIT WHEN find%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('name: ' || ffirst_name || ' surname: ' || flast_name || ' drug: ' || fname || ' price: ' || fprice || ' drugstore: ' || fdrugstore || ' address: ' || faddress);
   END LOOP;
   CLOSE find;
END show_order;
/

exec add_store('Apteka N1', 'Kharkiv', 'Sumskaya 6');
exec add_store('Apteka N2', 'Kharkiv', 'Chkalova 19');
exec add_store('Apteka N3', 'Kharkiv', 'Bluhera 50');

exec add_drug_group('antibiotic');
exec add_drug_group('steroid');
exec add_drug_group('tabletka');

exec add_drug('citramon', 20, 25, 'tabletka');
exec add_drug('analgin', 10, 20, 'tabletka');
exec add_drug('ketanov', 34, 25, 'tabletka');
exec add_drug('nosfirin', 120, 25, 'antibiotic');
exec add_drug('fenozepam', 200, 25, 'antibiotic');
exec add_drug('metanol', 150, 25, 'steroid');
exec add_drug('testosteron', 340, 25, 'steroid');

exec add_client('Denis', 'Domenko');
exec add_client('Ivan', 'Petrov');

exec add_order('Denis', 'Domenko', 'citramon', 1);
exec add_order('Denis', 'Domenko', 'citramon', 1);
exec add_order('Denis', 'Domenko', 'fenozepam', 1);
exec add_order('Denis', 'Domenko', 'testosteron', 1);

exec add_order('Ivan', 'Petrov', 'fenozepam', 3);
exec add_order('Ivan', 'Petrov', 'testosteron', 2);