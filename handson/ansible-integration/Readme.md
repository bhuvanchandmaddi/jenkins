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
