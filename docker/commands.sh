#!/bin/bash

docker image ls
docker run redis
sudo find / -name "*.sock"
ls -la ~/.docker/run
cat ~/.docker/run/docker.sock