#!/bin/bash
set -x

sudo apt-get install curl htop deborphan samba openssh-server libnss3-tools

wget https://linuxinfra.wdf.sap.corp/ldt/scripts/ldt-support.sh
chmod 755 ldt-support.sh
