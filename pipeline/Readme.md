## CI/CD jenkins pipeline demo project

### Install docker inside docker
* In the docker file we created a volume i.e /var/run/docker.sock, this is important to run.
* Before copying it make sure to change the ownership of the file like shown below:
```
sudo chown jenkins:1000 docker.sock

Because enkins user is part of docker group
And inside container 1000 i.e group is mapped to jenkins user.
```
* Create a new directory inside pipline to store jenkins data(to persist jenkins) & changed owener of the directory to 1000

## Maven build creation
* Create a folder jenkins-app and clone the project inito it
```
mkdir jenkins-data && cd jenkins-app && git clone  https://github.com/bhuvanchandmaddi/simple-java-maven-app && cp -r simple-java-maven-app/* . && rm -rf simple-java-maven-app/*
```

### Create a jar using docker-container
* Run the below command, which will copy the project into the container and run the maven package command and the jar will be created
```
docker run --rm  -v /home/jenkins/jenkins/pipeline/java-app:/app -v /root/.m2/:/root/.m2/ -w /app maven:3.9-eclipse-temurin-17-alpine mvn -B -DskipTests clean package
```

### Create a script for building the jar
* Create a bash script for the same in jenkins/build (mvn.sh) file(why this particular folder? because we will create folder for rach stage later)

### Create a Dockerfile to run the jar
* Create a Dockerfile which will take the resulting jar and run it.
* Since it is java app, the base image should have java, see the dokcerfile in jenkins/build
* It requires the jar to pe placed in current folder. so copy the jar into the current folder.
```
docker build -f Dockerfile_Java . -t test

docker run test:latest
```
### Create a docker-compose file to bulid the image
* docker-compose file is available at jenkins/build
```
docker-compose -f docker-compose-build.yml build
```
Note: BUILD_TAG env is used in the pipeline, its is predefined env in jenkins which is jobname

### Create a bash script to automate build steps
Here there is a manual thing, we need to copy the jar file ftom java-apps/target to jenkins/build location
And we also need to run the mvn.sh script to create the jar file which will be placed in java-apps/target folder(We will handle this in jenkins file)

Lets automate copying the app logic using bash script so that we can call it in Jenkinsfile
```
#!/bin/bash

# Copy the new jar to the build location
cp -f java-app/target/*.jar jenkins/build/

echo "****************************"
echo "** Building Docker Image ***"
echo "****************************"

cd jenkins/build/ && docker-compose -f docker-compose-build.yml build --no-cache
```
* The Jenkinsfile is located in pipeline folder so we used relative path from there in the script

### Create build step in the Jenkisfile
Now it is easy peasy. We need to do 2 things
1. Call the mvn.sh script which will create the jar and place it in java-app/target folder
2. Call the build.sh file which will copy the tar into the jenkins/build folder and execute the docker-compose build command to build the image
```
pipeline {

    agent any
    
    stages {

        stage('Build') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
                    ./jenkins/build/build.sh
                '''
            }
        }
    }

```

## Maven test 

### Run mvn test using docker container
* Create a container form maven image and execut mvn test(Just like how we did for build)
```
docker run --rm  -v  /home/jenkins/jenkins/pipeline/java-app:/app -v /root/.m2/:/root/.m2/ -w /app maven:3.9-eclipse-temurin-17-alpine mvn -B -DskipTests test
```

### create a bash script to test
* We can use same mvn.sh script, just to keep them more readable, we will cretae a test folder in jenkins and copy the same script there
```
cp build/mvn.sh test/

./mvn mvn -B -DskipTests test
```

### Add the entry in Jenkinsfile
```
pipeline {

    agent any
    
    stages {

        stage('Build') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
                    ./jenkins/build/build.sh
                '''
            }
        stage('Test') {
            steps {
                sh '''
                    ./jenkins/test/mvn.sh mvn -B -DskipTests test
                '''
            }
        }
    }
}
```

## Push the docker image
Created a shell script to push the images to dockerhub, which is avilable in jenkins/push
```code
pipeline {

    agent any
    
    stages {

        stage('Build') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
                    ./jenkins/build/build.sh
                '''
            }
        stage('Test') {
            steps {
                sh '''
                    ./jenkins/test/mvn.sh mvn -B -DskipTests test
                '''
            }
        }
        stage('Push') {
            steps {
                sh '''
                    ./jenkins/test/push.sh
                '''
            }
        }
    }
}

```

## Deploy the image
**pre-requisite:**

Create an ec2-instance(or vm), and enable password less authentication using ssh key pairs and aslo install docker in it
```
machine details: <ec2 instance ip>
username: jenkins
copy the public key under ~/.ssh/authorized_keys folder 
Get the private key and paste contents to /opt/prod(For testing)
```
**Test the deployment manually:**
* Write the 3 parametrs required for the push scripts into an tmp file
1. Imagename: maven-project
1. Imagetag: 10
1. docker registry password: <your password>

Note: Copy the privatekey(using which you will connect to remote machine into /opt folder)

write them to /tmp/.auth file
```
echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $PASS >> /tmp/.auth

scp -i /opt/prod /tmp/.auth prod-user@linuxfacilito.online:/tmp/.auth
```

**Sequence of steps:**
* Build the image using mvn.sh file inside the build folder, we need to set BUILD-TAG env before running this
* This will create a dockcer image with maven-project:BUILD-TAG 
* pust the image to docker hub using push.sh 
* Execute the deploy.sh(only as shown in above block not entire contents), make sure to set PASS(password of docker registry) env using export
* The above script copies the /tmp/.auth file into the remote, where you want to deploy the application
* In the remote create a docker-compose file, which will run our image.
* Create a maven folder inside home directory and create a compose file
```
version: "3"
services:
  maven:
    image: "bmaddi/${IMAGE}:${TAG}"
    container_name: maven-app
```
* To run the above docker file we need to set IMAGE and TAG env in remote machine and we need to do docker login as well.
* Set all the 3 env's by fetching the content from the /tmp/.auth file
```
export IMAGE=$(sed -n '1p' /tmp/.auth)
export TAG=$(sed -n '2p' /tmp/.auth)
export PASS=$(sed -n '3p' /tmp/.auth)
```
* Now docker login using
```
docker login -u bmaddi -p ${PASS}
```
* Now execute the docker-compose up -d
* Execute below cms to verify deployment
```
docker logs maven-app
```
* Your container application is ready

### Automate the above steps
* Create a bash script, which will run the docker compose file in remote
```
#!/bin/bash

export IMAGE=$(sed -n '1p' /tmp/.auth)
export TAG=$(sed -n '2p' /tmp/.auth)
export PASS=$(sed -n '3p' /tmp/.auth)

docker login -u bmaddi -p $PASS
cd ~/maven && docker-compose up -d
```
* Create this script file in jenkins/deploy folder and copy ot to the remote using scp. So update the deploy.sh file
```
#!/bin/bash

echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $PASS >> /tmp/.auth

scp -i /opt/prod /tmp/.auth prod-user@linuxfacilito.online:/tmp/.auth
scp -i /opt/prod ./jenkins/deploy/publish prod-user@linuxfacilito.online:/tmp/publish
ssh -i /opt/prod prod-user@linuxfacilito.online "/tmp/publish"
```
* Now when you run the publish script, it will copy the file and run the docker-composefile
* Create the docker-compose file in deploy directory and copy it to remote(done by me)

### Add the deploy step in Jenkinsfile
```
 stage('Deploy') {
            steps {
                sh './jenkins/deploy/deploy.sh'
            }
        }
```

## Final steps 

### push changes to github
* copy the contents of the pipeline folder to git repo(github for ease)
* Copy the contents to /tmp location and initiazed git repo and pushed to gitlab project

### Create a jenkins job and add this git repo
* Create a pipeline job and add this declarative pipeline, by selecting script from scm and specify scm details
* The job will fail but we are interested in fetching the code from git and placing it in workspace directory

### update the path in mvn.sh
* when we excute in the pipeline, then the git project will be copied to the workspace dir(var/jenkins_home/workspace/maven-project inside container)
* But in our mvn.sh file we used the relative path ${PWD}, we should give this path
* Update the mvn.sh by storing(it is available in persisted folder/workspace) in WORKSPACE variable

### Create a credential for docker registy pass and add it to Jenkinsfile
* Create credential for docker registry password which we used in our scripts with name PASS
* Provide that to Jenkinsfile using credentials environment option

### Add the privatekey file into the jenkis container
* In the deploy script we used private key to connect to the remote machine but it is available in host machine
* copy the same contents to the jenkins container into the same path
```
docker cp /opt/prod jenkins:/opt/prod
```
* From the jenkins container connect to the remote machine because we need to do host verification manually for the first time
```
ssh -i /opt/prod jenkins@3.25.120.150
```

### Add post actions in build and test stages
* Inside Jenkinsfile, in build stage add post action item to store the artifact
* Similarly in test stage to get surefire reports

### Test manually running the pipeline
* Run the pipeline manually, if you see any issues related this (unable to unlink old (Permission denied)) then delete the project workspace present in jenkins-data/workspace

### Create a webbook for the project
* Click on this [link](https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project)



