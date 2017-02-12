#!/bin/bash
# Build script for webserver

#Fail on non-zero
set -e

# Host port mapping for testing-app
hostport=8010

echo VERSION=$(cat version.txt) > props.env

# Build the docker image for the application
sudo docker build --no-cache -t ${DOCKER_USERNAME}/http-app:snapshot .
imageid=$(sudo docker images | grep ${DOCKER_USERNAME}/http-app | grep snapshot | awk '{print $3}')
echo "Building docker image is over"

# Run the unit tests
#sudo docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.6 go test -v

# Check if a testing-app is running - if so, remove it
#cid=$(sudo docker ps --filter="name=testing-app" -q -a)
#if [ ! -z "$cid" ]
#then
#    sudo docker rm -f testing-app
#fi

# Run a container from the image and capture the container ID
cid=$(sudo docker run -d --name testing-app -p $hostport:80 ${DOCKER_USERNAME}/http-app:snapshot)
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
