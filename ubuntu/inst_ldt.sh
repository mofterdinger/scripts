#!/bin/bash
set -x

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl aptitude htop deborphan samba openssh-server libnss3-tools

wget -O ldt.certificates.sh https://linuxinfra.wdf.sap.corp/ldt/scripts/ldt.certificates.sh --no-check-certificate
chmod +x ldt.certificates.sh
sudo ./ldt.certificates.sh

wget -O ldt-support.sh https://linuxinfra.wdf.sap.corp/ldt/scripts/ldt-support.sh --no-check-certificate
chmod +x ldt-support.sh
