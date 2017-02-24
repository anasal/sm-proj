#!/bin/bash
# Build script for web server

# Stop script if a command returns non-zero value
set -e

# Host port mapping for test-app containter
hostport=8010

echo VERSION=$(cat version.txt) > props.env

# Check if test-app is running, if so, remove it
cid=$(sudo docker ps --filter="name=test-app" -q -a)
if [ ! -z "$cid" ]
then
    sudo docker rm -f test-app
fi

# Build the docker image for the application
sudo docker build --no-cache -t ${DOCKER_USERNAME}-websrv:snapshot .
imageid=$(sudo docker images | grep ${DOCKER_USERNAME}-websrv | grep snapshot | awk '{print $3}')

# Run a container from the image and capture the container ID
cid=$(sudo docker run -d --name test-app -p $hostport:80 ${DOCKER_USERNAME}-websrv:snapshot)
echo "cid=$cid" >> props.env
echo "IMAGEID=$imageid" >> props.env
cat props.env

# Get the IP address of the container
cip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${cid})

# Check the service is reachable, using seige engine
sudo docker run --rm rufus/siege-engine -g http://$cip:80/
[ $? -ne 0 ] && exit 1

# Clean up the container
sudo docker kill ${cid}
sudo docker rm ${cid}
