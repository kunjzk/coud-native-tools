#!/bin/bash

set -e

echo "Establishing a connection to the EC2 instance..."
ssh -i ~/.ssh/aws-priv-key.pem ec2-user@52.220.81.106

echo "Updating dnf..."
sudo dnf update -y

echo "Checking if dockerd is installed..."
which docker

if [ $? -ne 0 ]; then
    echo "dockerd is not installed"
    echo "Installing dockerd..."
    sudo dnf install -y dockerd
    which docker
fi

echo "Checking if podman is installed..."
which podman

if [ $? -ne 0 ]; then
    echo "podman is not installed"
    echo "Installing podman..."
    sudo dnf install -y podman
    which podman
fi

