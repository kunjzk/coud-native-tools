#!/bin/bash

set -e

echo "Connecting to EC2 and running remote commands..."
ssh -i ~/.ssh/aws-priv-key.pem ubuntu@52.220.81.106 << 'EOF'
  echo "Updating apt..."
  sudo apt-get update -y

  echo "Checking if dockerd is installed..."
  if ! command -v docker &> /dev/null; then
      echo "dockerd is not installed, installing..."
      sudo apt-get install -y docker.io
      sudo systemctl enable --now docker
  fi
  which docker

  echo "Checking if podman is installed..."
  if ! command -v podman &> /dev/null; then
      echo "podman is not installed, installing..."
      sudo apt-get install -y podman
  fi
  which podman

  echo "Running nginx container with docker..."
  sudo docker rm -f nginx 2>/dev/null || true
  sudo docker run -d --name nginx docker.io/library/nginx:latest
  sleep 5

  echo "Checking who owns the nginx container (docker)..."
  ps aux | grep nginx
  sudo docker stop nginx
  sleep 5

  echo "Running nginx container with podman..."
  podman rm -f nginx 2>/dev/null || true
  podman run -d --name nginx docker.io/library/nginx:latest
  sleep 5

  echo "Checking who owns the nginx container (podman)..."
  ps aux | grep nginx
  podman stop nginx
EOF
