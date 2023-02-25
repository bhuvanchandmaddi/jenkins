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
        stage('Build') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests test
                '''
            }
        }
    }
```
