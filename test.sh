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

# Host port mapping for testing-app
hostport=8010

# Check if testing-app is running, if so, kill it
cid=$(sudo docker ps --filter="name=websrv-test" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f websrv-test
fi

# Run the container, name it testing-app
echo Running the container, with --name=websrv-test
testing_cid=$(sudo docker run -d --name websrv-test -p $hostport:80  $IMAGEID)
echo "testing_cid=$testing_cid" >> props.env

# Get the container IP address, and run siege engine on it for 60 seconds
cip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${testing_cid})
sudo docker run --rm rufus/siege-engine  -b -t60S http://$cip:80/ > output 2>&1

# Check service availability
echo Checking service availability...
avail=$(cat output | grep Availability | awk '{print $2}')
echo $avail
# shell uses = to compare strings, bash ==
if [ "$avail" = "100.00" ]
then
    echo "Availability high enough"
    exit 0
else
    echo "Availability too low"
    exit 1
fi

# Check Hello World is available
sleep 5
if curl $cip:80 | grep -iq 'Hello World'; then
  echo "Test passed!"
  sudo docker tag $IMAGEID ${DOCKER_USERNAME}/http-app:stable
  exit 0
else
  echo "Test failed!"
  exit 1
fi

