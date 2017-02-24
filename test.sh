#!/bin/bash

# Run this after build.sh.
# Expects these environment variables:
#    IMAGEID - The docker image id to test
#    DOCKER_USERNAME - The docker username for naming repositories
#
# Can run this script after build.sh as:
#    env $(cat param.env | xargs) ./test.sh

# Stop script if a command return a non-zero value
set -e

# Host port mapping for test-app
hostport=8010

# Check if test-app is running, if so, remove it
cid=$(sudo docker ps --filter="name=test-app" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f test-app
fi

# Run the container, name it test-app
echo Running the container, with --name=test-app
testing_cid=$(sudo docker run -d --name test-app -p $hostport:80  $IMAGEID)
echo "testing_cid=$testing_cid" >> param.env
cat param.env

# Get the container IP address
cip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${testing_cid})

# Check Hello World is available
sleep 15
if curl $cip:80 | grep -iq 'Hello World'; then
  echo "Hello World Test passed!"
  sudo docker tag $IMAGEID ${DOCKER_USERNAME}-websrv:stable
  exit 0
else
  echo "Hello World Test failed!"
  exit 1
fi
