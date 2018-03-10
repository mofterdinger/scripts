#!/bin/bash
set -x

PHY_VOL=/dev/sda2
VOL_GRP=vg1

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

modprobe dm_mod

#########################
# create physical volume
#########################
pvcreate "$PHY_VOL"
pvdisplay

######################
# create volume group
######################
vgcreate "$VOL_GRP" "$PHY_VOL"
vgdisplay

#########################
# create logical volumes
#########################
lvcreate --name root -L30G $VOL_GRP
lvcreate --name swap -L16G $VOL_GRP
lvcreate --name home -l100%FREE $VOL_GRP
lvdisplay
