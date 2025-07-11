#!/bin/bash

source docker-cli/.env

# Single command with authentication
skopeo copy \
  --src-creds=$QUAY_USERNAME:$QUAY_PASSWORD \
  --dest-creds=$GITHUB_USERNAME:$GITHUB_TOKEN \
  docker://quay.io/app-sre/ubi8-ubi-minimal:latest \
  docker://ghcr.io/$GITHUB_USERNAME/ubi8-ubi-minimal:latest