#!/bin/bash

source .env
echo $QUAY_PASSWORD | docker login -u $QUAY_USERNAME --password-stdin quay.io
docker pull quay.io/app-sre/ubi8-ubi-minimal:latest
docker image ls
docker tag quay.io/app-sre/ubi8-ubi-minimal:latest ghcr.io/$GITHUB_USERNAME/ubi8-ubi-minimal:latest
docker image ls
echo $GITLAB_TOKEN | docker login ghcr.io -u $GITLAB_USERNAME --password-stdin
docker push ghcr.io/$GITHUB_USERNAME/ubi8-ubi-minimal:latest
docker rmi quay.io/app-sre/ubi8-ubi-minimal:latest
docker rmi ghcr.io/$GITHUB_USERNAME/ubi8-ubi-minimal:latest