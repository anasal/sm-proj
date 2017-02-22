#!/bin/bash

# Run this after build.sh.
# Expects these environment variables:
#
#    IMAGEID - The docker image id to test
#    DOCKER_USERNAME - The docker username for naming repositories
#
# Can run this as to use the file generated from build.sh:
#
#    env $(cat props.env | xargs) ./test.sh

#Fail on non-zero
set -e

# Host port mapping for test-app
hostport=8010

# Check if test-app is running, if so, kill it
cid=$(sudo docker ps --filter="name=test-app" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f test-app
fi

# Run the container, name it testing-app
echo Running the container, with --name=test-app
testing_cid=$(sudo docker run -d --name test-app -p $hostport:80  $IMAGEID)
echo "testing_cid=$testing_cid" >> props.env

# Get the container IP address, and run siege engine on it for 60 seconds
cip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${testing_cid})
sudo docker run --rm rufus/siege-engine  -b -t60S http://$cip:80/ > output 2>&1

# Check Hello World is available
sleep 5
curl $cip
if curl $cip:80 | grep -iq 'Hello World'; then
  echo "Test passed!"
  exit 0
else
  echo "Test failed!"
  exit 1
fi


