#!/bin/bash

podman ps

if [ $? -ne 0 ]; then
    echo "Podman is not running"
    exit 1
fi