#!/bin/bash

set -e

echo "Connecting to EC2 and running remote commands..."
ssh -i ~/.ssh/aws-priv-key.pem ubuntu@13.213.138.120 << 'EOF'
  echo "Waiting for apt lock to be released..."
  while sudo lsof /var/lib/dpkg/lock-frontend &>/dev/null; do sleep 2; done
  sudo systemctl stop unattended-upgrades 2>/dev/null || true

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

  docker pull docker.io/library/nginx:latest
  podman pull docker.io/library/nginx:latest

  echo ""
  echo ""
  echo "--------------------------------"

  echo "Running nginx container with docker..."
  sudo docker rm -f nginx 2>/dev/null || true
  sudo docker run -d --name nginx docker.io/library/nginx:latest &>/dev/null
  sleep 5

  echo "Checking ownership of nginx process"
  ps aux | grep nginx
  sudo docker stop nginx &>/dev/null
  sleep 5
  echo ""
  echo ""
  echo "--------------------------------"

  echo "Running nginx container with podman..."
  podman rm -f nginx 2>/dev/null || true
  podman run -d --name nginx docker.io/library/nginx:latest &>/dev/null
  sleep 5

  echo "Checking ownership of nginx process"
  ps aux | grep nginx
  podman stop nginx &>/dev/null
  echo ""
  echo ""
  echo "--------------------------------"
EOF
