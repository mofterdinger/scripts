#!/bin/bash
set -x

NAME=gitlab

docker rm $NAME

docker run --detach \
  --hostname wdfl33450964a.dhcp.wdf.sap.corp \
  --publish 443:443 --publish 80:80 --publish 1022:22 \
  --name $NAME \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
