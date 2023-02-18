## Integration with maven

### Download plugins
* Install maven and git plugins
* Name of maven plugin is "Maven Integration"
* Git plugin is installed by default, if you allowed recommended plugins, else download now and plugin name was "Git plugin"

### Get the maven project and create a job
* Get the sample maven application from [here](https://github.com/bhuvanchandmaddi/simple-java-maven-app.git)
* Create a job by cloning this project
* Execute the job and test it
* It should download the project into the below location in jenkins master i.e jenkins container in our case
>/var/jenkins_home/workspace/MavenProject

### Download maven in jenkins master
* Download maven in jenkins master, let jenkins download for us by specifying maven version in "Global Tool configuration"

### Add build options to package and test
* Extended this job by running maven build 
* Under Build steps select *Invoke top level maven targers* and paste below code
>-B -DskipTests clean package
* This will build the project and creates a jar and places it in targes folder i.e **/var/jenkins_home/workspace/MavenProject/target/my-app-1.0-SNAPSHOT.jar** in our case
* First time it will take time as it needs to download all the dependencies. From the next job it will be much faster
* add other postbuild option to execute mvn test
>test

### Add build option to deploy the jar created earlier
* Create a build option to execute the shell command
```code
echo "*************************"
echo "Deploying the application"
echo "*************************"
java -jar /var/jenkins_home/workspace/MavenProject/target/my-app-1.0-SNAPSHOT.jar
```

### Add a post build action to display oir job deployment status as graph
* Post build action -> Publish Junit result report
* Add the reports relative path
>target/surefire-reports/*.xml
* Execute the job 2-3 times so that you can see the graph in job page

### Arcgieve last successful artifact
* The last successful jar will be displayed in the job page, so anyone can download it
* Create a post build action -> Archieve the artifacts and specify the path to the jar
>target/*.jar
* Advanced -> enable check box of Archive artifacts only if build is successful