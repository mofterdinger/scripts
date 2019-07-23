#!/bin/bash
set -x

NAME=gitlab

docker stop $NAME

docker rm $NAME


# see: https://docs.gitlab.com/omnibus/docker/

docker run --detach \
  --hostname wdfl33450964a.dhcp.wdf.sap.corp \
  --publish 443:443 --publish 80:80 --publish 1022:22 \
  --name $NAME \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab:Z \
  --volume /srv/gitlab/logs:/var/log/gitlab:Z \
  --volume /srv/gitlab/data:/var/opt/gitlab:Z \
  gitlab/gitlab-ce:latest
