#!/bin/bash

set -e

# Unit file for Nginx Container (Podman)
# [Unit]
# Description=Nginx Container (Podman)
# After=network-online.target
# Wants=network-online.target

# [Service]
# Restart=always
# RestartSec=5

# ExecStart=/usr/bin/podman run \
#   --name nginx-demo \
#   --replace \
#   -p 80:80 \
#   docker.io/library/nginx:latest

# ExecStop=/usr/bin/podman stop nginx-demo
# ExecStopPost=/usr/bin/podman rm -f nginx-demo

# TimeoutStopSec=30

# [Install]
# WantedBy=multi-user.target

echo "Connecting to EC2 and running remote commands..."
ssh -i ~/.ssh/aws-priv-key.pem ubuntu@54.251.33.31 << 'EOF'
  sudo systemctl daemon-reload
  sudo systemctl enable nginx-container
  sudo systemctl start nginx-container
  sudo systemctl status nginx-container
  sudo systemctl stop nginx-container
EOF
