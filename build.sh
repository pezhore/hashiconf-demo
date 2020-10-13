#!/bin/bash

# Cleanup the terraform things

[ -d ./deploy/.terraform ] && sudo rm -rf ./deploy/.terraform
[ -f ./deploy/.terraform.tfstate ] && sudo rm -rf ./deploy/.terraform.tfstate

# Kill and remove the demo container
docker kill hashiconf-demo
docker rm hashiconf-demo

# Build and run with the environment file
docker build -t hashiconf-demo .
docker run -d \
    --name hashiconf-demo \
    --env-file docker_env \
    -v ${PWD}/deploy:/work \
    -t hashiconf-demo 