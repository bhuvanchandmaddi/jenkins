WORKSPACE=/home/jenkins/jenkins/pipeline/jenkins-data/workspace/maven-project
echo "***************************"
echo "** Testing jar ***********"
echo "***************************"

docker run --rm  -v  $WORKSPACE/java-app:/app -v /root/.m2/:/root/.m2/ -w /app maven:3.9-eclipse-temurin-17-alpine "$@"
