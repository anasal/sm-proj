#!/bin/bash

# Can run this as to use the file generated from build.sh:
#
#    env $(cat props.env | xargs) ./deploy.sh

#Fail on non-zero
set -e

# Host port mapping for deploy-app
hostport=8020

sudo docker tag ${DOCKER_USERNAME}/http-app:stable ${DOCKER_USERNAME}/http-app:latest
cmd="sudo docker tag ${DOCKER_USERNAME}/http-app:stable ${DOCKER_USERNAME}/http-app:$VERSION"
eval $cmd

# no git here yet
# sudo docker tag http-app/http-app:$(git describe)

# Remove existing deployed application
cid=$(sudo docker ps --filter="name=deploy-app" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f deploy-app
fi
sudo docker run -d --name deploy-app -p $hostport:80 ${DOCKER_USERNAME}/http-app:latest

sudo docker ps |grep ${DOCKER_USERNAME}/http-app
sudo docker images |grep ${DOCKER_USERNAME}/http-app
