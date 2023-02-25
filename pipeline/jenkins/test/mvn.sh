docker run --rm  -v  /home/jenkins/jenkins/pipeline/java-app:/app -v /root/.m2/:/root/.m2/ -w /app maven:3.9-eclipse-temurin-17-alpine "$@"
