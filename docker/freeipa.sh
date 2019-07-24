#!/bin/bash
set -x

NAME=freeipa-server

docker stop $NAME

docker rm $NAME

docker run --name $NAME -ti \
   -h ipa.example.test \
   -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
   --tmpfs /run \
   --tmpfs /tmp \
   -v /var/lib/ipa-data:/data:Z freeipa-server [ opts ]
