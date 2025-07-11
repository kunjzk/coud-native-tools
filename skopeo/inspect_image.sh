#! /bin/bash

source docker-cli/.env

skopeo inspect docker://quay.io/app-sre/ubi8-ubi-minimal:latest