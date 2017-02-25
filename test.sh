#!/bin/bash

# Can run this script after build.sh as:
#    env $(cat props.env | xargs) ./test.sh

# Stop script if a command return a non-zero value
set -e

# Host port mapping for test-app
hostport=8010

# Run the container, name it test-app
echo Running the container, with --name=test-app
test_cid=$(sudo docker run -d --name test-app -p $hostport:80  $IMAGEID)
echo "test_cid=$test_cid" >> props.env

# Get the container IP address
cip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${test_cid})

# Check Hello World is available

if curl $cip | grep -iq 'Hello World'; then
  echo "Hello World Test passed!"
  sudo docker tag $IMAGEID ${DOCKER_USERNAME}-websrv:stable
  exit 0
else
  echo "Hello World Test failed!"
  exit 1
fi
