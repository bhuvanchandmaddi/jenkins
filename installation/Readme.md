## Manual Installation:
>#### Creation of jenkins user
* Create a user with name jenkins
***useradd jenkins***
* set password for jenkins
***passwd jenkins***
* Make him admin(add him to sudo'ers group)
***usermod -aG wheel jenkins***

**Note:** In debian machines, admin group is sudo and in redhat distributions it is called wheel

>#### Installing docker:
* Update the packages on your instance
***sudo yum update -y***
* Install Docker
***sudo yum install docker -y***
* Start the Docker Service
***sudo service docker start***
or
***systemctl start jenkins
systemctl enable jenkins***
* Add user jenkins to docker group
***sudo usermod -a -G docker jenkins***
**Note:** You should then be able to run all of the docker commands without requiring sudo. After running the 4th command I did need to logout and log back in for the change to take effec

>#### Installing docker compose
* sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
* sudo chmod +x /usr/local/bin/docker-compose
* docker-compose version

>#### Integration with docker