#!/bin/bash

# Can run this script after test.sh as:
#    env $(cat param.env | xargs) ./deploy.sh

# Stop script if a command returns a non-zero value
set -e

DOCKER_USERNAME=anas

# Host port mapping for deploy-app
hostport=8020

# Tag the stable websrv image with latest and version
sudo docker tag ${DOCKER_USERNAME}-websrv:stable ${DOCKER_USERNAME}-websrv:latest
cmd="sudo docker tag ${DOCKER_USERNAME}-websrv:stable ${DOCKER_USERNAME}-websrv:$VERSION"
eval $cmd

# Remove existing deployed application if any
cid=$(sudo docker ps --filter="name=deploy-app" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f deploy-app
fi

# Create deploy-app container
sudo docker run -d --name deploy-app -p $hostport:80 ${DOCKER_USERNAME}-websrv:latest

# Display created images and containers
sudo docker ps |grep ${DOCKER_USERNAME}-websrv
sudo docker images |grep ${DOCKER_USERNAME}-websrv
