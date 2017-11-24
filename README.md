## Oracle DB for local use in docker

1. Intsall <a href="https://docs.docker.com/engine/installation/">docker</a> and <a href="https://docs.docker.com/compose/install/">docker-compose</a>;
2. Run `docker-compose up` or `docker-compose up -d` ;
3. Wait few minutes to download image and for db start (it takes 3-4 minutes);
4. Go to <a href="http://localhost:8080/apex">http://localhost:8080/apex</a>
5. Fill form  
workspace: INTERNAL  
user: ADMIN  
password: oracle  
6. On next screen change password to your own;
7. Log in with new password;
8. Go to "Manage Workspaces" -> Create Workspace
9. fill form (I use test for all pages)
10. Open terninal and execute `docker exec -it oracle_db sqlplus <username>/<password>` in my case it is `docker exec -it oracle_db sqlplus test/test`
11. Enter user-name and password
12. ...  
13. PROFIT! 


### Creating two workspaces and create link between them

1. Create second workspace with another user and db schema
2. Grant privileges to users for creating links and sessions    
   - execute in terminal `docker exec -it oracle_db sqlplus /nolog`  
   - then execute `conn sys/oracle as sysdba`
   - execute next 4 commands for your users:  
   \- `grant dba to <username>;` - to grant admin privileges
   \- `grant CREATE DATABASE LINK to <username;` - to grant privileges for link creation  
   \- `grant CREATE PUBLIC DATABASE LINK to <username;` - to grant privileges for public link creation  
   \- `grant CREATE SESSION to <username;` - to grant privileges for session creation
3. Then open sqlplus and log in
4. Create link using next command:
  - `create database link <linkname>`     
       `connect to <username>`    
       `identified by <password>`    
       `using 'localhost:1521/xe';`
   