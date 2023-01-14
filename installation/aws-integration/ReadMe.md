>### project:
Create a mysql database, insert data into it. Backup data and place backup file in s3
**Note:** Persist the script file as well, which will be used to perform the automation

>### **Steps:**
* Using the same docker-compose file(1 service for installing jenkins and other service for running ssh instance)
* Created a new service in the backup file to spinup mysql database
* Updated remote ssh host machine Dockerfile to install aws-cli and mysql client
* Created a bash script to execute backup dump command and push the backfile lo aws s3
* Created an aws IAM user(to get aws creds) and s3 bucket
* For persisting the script, created a volume in remote-host service

>### To create sample data in mysql db:
After docker compose up -d, execute below commands to create testdata which is used for backup
1. exec into jenkins-host machine, this is where we have aws-cli.sh script
1. connect to mysql db
>mysql -u root -h db_host -p
3. list default databases, using cmd:
> show databases;
4. create dabatase
> create database test_db
5. To switch to current databse
>use test_db;
6. create sample table
> create table info (name varchar(20), lastname varchar(20), age int(2));
7. list tables, to verify
> show tables;
8. To get metedata of the table
>desc info;
9. Insert data into above table:
>insert into info values('bhuvan','maddi',24);
 insert into info values('samatha','akkeneni',30);
 insert into info values('jai balayya','nandamuri',60);
 10. To view data in the table
 > select * from info;