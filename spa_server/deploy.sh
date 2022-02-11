#!/bin/bash

set -x

# Build docker image
docker build -t dart-spa-boilerplate .

# Login to AWS ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 517598257794.dkr.ecr.eu-central-1.amazonaws.com

# Tag and push to AWS
docker tag dart-spa-boilerplate 517598257794.dkr.ecr.eu-central-1.amazonaws.com/dart-spa-boilerplate:latest
docker push 517598257794.dkr.ecr.eu-central-1.amazonaws.com/dart-spa-boilerplate:latest

# Deploy new service from latest docker container
aws ecs update-service --cluster dart-spa-boilerplate --region eu-central-1 --service dart-spa-boilerplate --force-new-deployment