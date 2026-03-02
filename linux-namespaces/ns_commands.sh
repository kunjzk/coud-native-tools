#! /bin/bash

ps -ef --forest
podman run -d --name nginx docker.io/library/nginx:latest
ps -ef --forest
sudo unshare --fork --pid --mount-proc bash
ps -ef --forest
cat /proc
cat /proc | grep -E '^[0-9]+' | wc -l
lsns -t pid