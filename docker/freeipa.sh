#!/bin/bash
set -x

NAME=freeipa-server
SERVER_PASSWORD=password
ADMINT_PASSWORD=admin-password

docker stop $NAME

docker rm $NAME

docker run --name $NAME -ti \
   -h ipa.example.test \
   -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
   --tmpfs /run \
   --tmpfs /tmp \
   -v /srv/freeipa/data:/data:Z \
   --realm=example.test \
   --tmpfs /tmp \
   --password=$SERVER_PASSWORD \
   --admin-password=$ADMIN_PASSWORD \
   freeipa/freeipa-server
