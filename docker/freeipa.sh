#!/bin/bash
set -x

NAME=freeipa-server
SERVER_PASSWORD=ds-password
ADMIN_PASSWORD=admin-password
HOSTNAME=ipa.example.test
SERVER_IP=127.0.0.1

docker stop $NAME

docker run --rm \
  --name     $NAME \
  --env      IPA_SERVER_IP=$SERVER_IP \
  --publish  80:80 -p 443:443 \
  --publish  389:389 -p 636:636 \
  --publish  88:88 -p 464:464 -p 88:88/udp -p 464:464/udp \
  --publish  123:123/udp \
  --publish  9443:9443 -p 9444:9444 -p 9445:9445 \
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
