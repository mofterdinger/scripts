#!/bin/bash

sudo docker run --detach \
  --hostname wdfl33450964a.dhcp.wdf.sap.corp \
  --publish 443:443 --publish 80:80 --publish 1022:22 \
  --name gitlab \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
