#!/bin/bash

echo "********************"
echo "** Pushing image ***"
echo "********************"

IMAGE="maven-project"
DOCKER_REPO="bmaddi"

echo "** Logging in ***"
docker login -u $DOCKER_REPO -p $PASS
echo "*** Tagging image ***"
docker tag $IMAGE:$BUILD_TAG $DOCKER_REPO/$IMAGE:$BUILD_TAG
echo "*** Pushing image ***"
docker push $DOCKER_REPO/$IMAGE:$BUILD_TAG