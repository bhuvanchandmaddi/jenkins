echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $PASS >> /tmp/.auth

scp -i /opt/prod /tmp/.auth jenkins@3.25.120.150:/tmp/.auth
ssh -i /opt/prod jenkins@3.25.120.150 "mkdir -p ~/maven "
scp -i /opt/prod ./jenkins/deploy/publish.sh jenkins@3.25.120.150:/tmp/publish.sh
ssh -i /opt/prod jenkins@3.25.120.150 "/tmp/publish.sh"

