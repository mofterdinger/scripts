gdisk /dev/sda
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

pvcreate /dev/sda2

vgcreate tank /dev/sda2

lvcreate --name lvol-root -L30G tank

lvcreate --name lvol-swap -L16G tank

lvcreate --name lvol-home -l50%FREE tank
