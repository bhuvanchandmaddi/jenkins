### Installation of ansible
In the docker-compose file we have 3 services.
1. Jenkins
2. remote ssh host
3. mysql 

* Let us create a docker file by extending jenkins image to install docker
* We are executing the compose file as a jenkins user and jenkins container is running with root context.
* So we need to switch the context to root and install ansible using root and again switch back to jenkins user in Dockerfile

### copy the ssh key permanently on jenkins container using docker volumes
* we need to create a folder with name ansible in volume(jenkins-data) in our case and copy the ssh private key
* So that even when containers are deleted data will be persisted. when a new container is created data will always be loaded.

**But why we are copying this key ino the container??**
Because jenkins container is ansible master and remote host is our ansible slave machine.
So if we want to connect to slave we need a user i.e remote_user in our case and then we need his private key to mention in ansible inventory file. That's why we are copying it to the jenkins container where ansible is installed

### Inventory file
* Inventory or host file need to be copied into the container and best way is via volumes

### Ansible testing manually execing into jenkins container

* We have ansible and host file ready in container with slave as remote-host.
* You can run adhoc commands to test.
EG: adhoc ping

```code
anisble -i hosts all -m ping
```
-m -> Module
-i -> inventory location
all -> host defined in inventory(It could be alais name of single host,group or all etc)
* You can run the playbook similarly
```code
ansible-playbook -i hosts playbook.yaml
```
**Note:** Before executing the playbook check for syntax error using -**-syntax-check** option

### Ansible testing form jenkins ui
* Install ansible plugin
* Under build section you will see a new option for ansible
* Specify playbook & inventory location and give variable if needed by creating a parameter.So that you can change that value dynamically

### colorize playbook output
* Install another plugin called ansicolor to see the colors for playbook. Like how you saw them when executed manually.
* Under configuration enable 2 checkboxes:
Build Environmanet ->Color ANSI Console Output
Build step -> Ansible Advanced -> Colorized stdout

### Sample project
To run a php application which displays the information of users(First name,last name and age) based on the age selected.

**How we are doing this?**
* Get a file which contains random people names
* Create a nginx webserver and install php
* Store the randon peoople info in mysql database
* Show the info of the people matching the age selected on home page

### Detailed steps:

#### 1.Enter dummy data into mysql db
* From the docker compose file we can create a mysql database
* Enter dummy data using bash script by creating a database with name people
```code
# connect to the database
 docker exec -it db bash
 mysql -u root -p
 enter: password when it asks for promt
 # to list databases
 show databases;

# create people db
create database people;

# switch to people db
use people;

# Create a table
create table register(id int(3),name varchar(50), lastname varchar(50), age int(3));

# To see contents of the table
select * from register;

# To see metadata
desc register;

```
* The file contains names only, age can be given using shuf which generates randon number in the given range
* copy both people.txt and put.sh files into remote-host container. Because it has mysql client
```code
docker cp perople.txt remote-host:/tmp/
docker cp put.sh remote-host:/tmp/

```
* Execute the script and then verify  all enteries are properly inserted or not bt listing conenects of db.

#### 2. Create the nginx webserver with php installed:
* Add a new service to the docker-compose file to create nginx webserver
* Build this image by extending remote-host image(which is built based on centos).
* Because we will have mysql client,remote_user etc
* We also need nginx conf and index.php file
    * nginx.conf ->configuration of nginx
    * nginx.repo -> repo info of nginx
* Pay some attention on folder structure.Dockefile and above 2 files are placed in web folder.
* Build the image and run
```code
docker-compose build
docker-compose up -d
```

#### 3.copy the