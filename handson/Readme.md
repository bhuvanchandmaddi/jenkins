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

>#### Jenkins installation setup with dockercompose:
* To install docker
docker-compose up -d

**Note:** Most ot the time you will get permissions issues.This is because, the /var/jenkins_home directory inside container is owned by jenkins user with uid 1000.So if you want to link a volume make sure the directory should be owned by user with same uid(i.e 1000).Here user is not important but only uid is important.Even if same uid is used by other user.

> sudo chown -R 1000:1000 <location on ec2-instance>

>#### Install remote-host with dockercompose:
* Created dockerfile in dockerslaves/
* Created ssh keys and copied public key to conatiner
* Added private key in jenkins and created a jenkins creds with that
* Inatlled ssh plugin
* configured ssh to run basic task in remote shell
* Finally executed docker-compose up -d, which launches 2 conatiners

