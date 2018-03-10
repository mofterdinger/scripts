#!/bin/bash
set -x

PHY_VOL=/dev/sda2
VOL_GRP=tank

lvremove -f /dev/$VOL_GRP
vgremove -f $VOL_GRP
umount /dev/sda1
umount /dev/sda2

####################
# create partitions
####################
gdisk /dev/sda <<< '
o
y
n
1

+512M
ef00
n
2

+200G
8e00
w
y
'

#########################
# create physical volume
#########################
pvcreate "$PHY_VOL"

######################
# create volume group
######################
vgcreate "$VOL_GRP" "$PHY_VOL"

#########################
# create logical volumes
#########################
lvcreate --name lvol-root -L30G $VOL_GRP
lvcreate --name lvol-swap -L16G $VOL_GRP
lvcreate --name lvol-home -l50%FREE $VOL_GRP

ls /dev/mapper
