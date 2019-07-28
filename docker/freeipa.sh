#!/bin/bash
set -x

NAME=freeipa-server
SERVER_PASSWORD=ds-password
ADMIN_PASSWORD=admin-password

docker stop $NAME

docker run --rm -ti \
  --name $NAME \
  -h ipa.example.test \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --tmpfs /run \
  --tmpfs /tmp \
  -v /srv/freeipa/data:/data:Z \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  freeipa/freeipa-server \
  exit-on-finished \
  -U \
  --ds-password=$SERVER_PASSWORD \
  --admin-password=$ADMIN_PASSWORD \
  --realm=example.test
