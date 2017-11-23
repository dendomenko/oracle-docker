## Oracle DB for local use in docker

1. Intall <a href="https://docs.docker.com/engine/installation/">docker</a> and <a href="https://docs.docker.com/compose/install/">docker-compose</a>;
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
10. Open terninal and execute `docker exec -it oracle_db sqlplus <username>/<password>@<dbname>` in my case it is `docker exec -it oracle_db sqlplus test/test@test`
11. Enter user-name and password
12. ...  
13. PROFIT! 