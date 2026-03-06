#! /bin/bash

yes > /dev/null &
ps aux | grep yes
sudo mkdir /sys/fs/cgroup/mygroup
echo "2478" | sudo tee /sys/fs/cgroup/mygroup/cgroup.procs # PID of the yes process
echo "20000 100000" | sudo tee /sys/fs/cgroup/mygroup/cpu.max # <quota> <period> in microseconds
top