#!/bin/bash
set -x

NAME=freeipa-server
SERVER_PASSWORD=ds-password
ADMIN_PASSWORD=admin-password
HOSTNAME=ipa.example.test
SERVER_IP=127.0.0.1

docker stop $NAME

docker run --rm \
  --name $NAME \
  --env  IPA_SERVER_IP=$SERVER_IP \
  --publish  80:80 -p 443:443 \
  --hostname $HOSTNAME \
  --tmpfs    /run \
  --tmpfs    /tmp \
  --volume   /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --volume   /srv/freeipa/data:/data:Z \
  --sysctl   net.ipv6.conf.all.disable_ipv6=0 \
  --detach \
  freeipa/freeipa-server \
  exit-on-finished \
  -U \
  --ds-password=$SERVER_PASSWORD \
  --admin-password=$ADMIN_PASSWORD \
  --realm=example.test
