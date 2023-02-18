### Installation of gitlab using docker
* After running the docker-compose file access the gitlab server at publicip:8090
* Initail login creds:
username: root
password: exec into container and see here /etc/gitlab/initial_root_password
* Create a user and login using this user
* Create a group and project. So he is owner of this project
* Upload sample maven project to this git repo
* This can be done by cloning actual repo from github to local machine and clone gitlab empty repo to the same machine
* Copy files from github clone location to gitlab location and commit and push

>Note: while conong repo from gitlab make use the address is resolvable i.e include the port number and add the domain name in /etc/hosts

Eg: http://gitlab.example.com/devops/mavensamplerepo.git

If your repo is like this then add **gitlab.example.com** in */etc/hosts* to point to localhost and then insert 8090 port after that since our container is running in that port
Final url: http://gitlab.example.com:8090/devops/mavensamplerepo.git

### Integrate your gitserver to Maven Job
* In the earlier class, we created a jenkins job which fetches the code form github
* Update the job to fetch the code from our gitlab server.
* Add credentials in jenkins, because our gitlab server requires authentication
> Note: This step is mandatory only when you create your project as private in gitlab
* The gitlab url need to be updated 

Actual url: http://gitlab.example.com:8090/devops/mavensamplerepo.git
* The jenkins container doesn't resolve gitlab.example.com dns beacause this conatiner has no dns info of this domain we updated /etc/hosts file of local machine only
* But git-server is a container and all our containers live in same networking. Jenkins container can reach gitlab-server container using service name i.e git(see in docker-compose file) in our case.
* Port 8090 is host port but the container port is 80, since communication is hapenning inside the conatiner we need to use container port i.e 80
Final url: http://git:80/devops/mavensamplerepo.git

## Webhooks
Lets trigger this job when we make any commits to our project using webhooks

* Create a user in jenkins, who will trigger the jobs
* Create a role with read and build permissions to jobs, assign that role to gitlab user
* Now in gitlab server, navigate to settings -> Integration -> Jenkins
* Enter the jenkins url, project name and username and password(The one we created above for this purpose)
