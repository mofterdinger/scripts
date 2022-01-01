#!/bin/bash
set -x

#############################
# variables
#############################
CONTAINER=cryptlvm
CONT_VOL=/dev/mapper/$CONTAINER
PHY_VOL=/dev/sda2
VOL_GRP=vg1
HOSTNAME="archlinux-zbook"
KEYMAP=de-latin1

#############################
# unmount current partitions
#############################
umount /dev/sda1
umount /dev/sda2
umount /dev/$VOL_GRP/root
umount /dev/$VOL_GRP/home
swapoff /dev/$VOL_GRP/swap

#############################
# remove volume group
#############################
lvremove -f /dev/$VOL_GRP
vgremove -f $VOL_GRP

set -e

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


8e00
w
y
'

modprobe dm_mod

cryptsetup luksFormat $PHY_VOL
cryptsetup open $PHY_VOL $CONTAINER

#########################
# create physical volume
#########################
pvcreate $CONT_VOL
pvdisplay

######################
# create volume group
######################
vgcreate $VOL_GRP $CONT_VOL
vgdisplay

#########################
# create logical volumes
#########################
lvcreate --name swap -L 32G $VOL_GRP
lvcreate --name root -L 30G $VOL_GRP
lvcreate --name home -L 250G $VOL_GRP
lvdisplay

#########################
# format logical volumes
#########################
mkfs.fat -F 32 -n EFIBOOT /dev/sda1
mkfs.ext4 -F -L lv_root /dev/$VOL_GRP/root
mkfs.ext4 -F -L lv_home /dev/$VOL_GRP/home 
mkswap -L lv_swap /dev/$VOL_GRP/swap

#########################
# mount logical volumes
#########################
mount -L lv_root /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount -L EFIBOOT /mnt/boot
mount -L lv_home /mnt/home
swapon -L lv_swap

reflector --country Germany

pacstrap /mnt base linux linux-lts linux-firmware intel-ucode
genfstab -p /mnt > /mnt/etc/fstab

echo $HOSTNAME > /mnt/etc/hostname
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf
echo KEYMAP=$KEYMAP > /mnt/etc/vconsole.conf

#####################################
# enable locales in locale.gen
#####################################
echo "de_DE.UTF-8 UTF-8
de_DE ISO-8859-1
de_DE@euro ISO-8859-15
en_US.UTF-8 UTF-8
en_US ISO-8859-1
" >> /mnt/etc/locale.gen

#####################################
# add bootloader entries
#####################################
mkdir -p /mnt/boot/loader/entries

UUID=`blkid -s UUID -o value $PHY_VOL`

echo "# https://systemd.io/BOOT_LOADER_SPECIFICATION/#type-1-boot-loader-specification-entries
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options rd.luks.name=$UUID=$CONTAINER root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch.conf

echo "# https://systemd.io/BOOT_LOADER_SPECIFICATION/#type-1-boot-loader-specification-entries
title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /intel-ucode.img
initrd  /initramfs-linux-lts.img
options rd.luks.name=$UUID=$CONTAINER root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-lts.conf

echo "# https://systemd.io/BOOT_LOADER_SPECIFICATION/#type-1-boot-loader-specification-entries
title   Arch Linux Fallback
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options rd.luks.name=$UUID=$CONTAINER root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-fallback.conf

echo "# https://systemd.io/BOOT_LOADER_SPECIFICATION/#type-1-boot-loader-specification-entries
title   Arch Linux LTS Fallback
linux   /vmlinuz-linux-lts
initrd  /intel-ucode.img
initrd  /initramfs-linux-lts-fallback.img
options rd.luks.name=$UUID=$CONTAINER root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-lts-fallback.conf

echo "# https://man.archlinux.org/man/loader.conf.5#OPTIONS
default arch.conf
timeout 10
console-mode max
auto-entries 1
auto-firmware 1" > /mnt/boot/loader/loader.conf

#####################################
# manual configuration
# 1. fstab: add option discard
# 2. mkinitcpio.conf:
# MODULES=(i915 intel_agp)
# HOOKS=(base systemd autodetect modconf block sd-vconsole lvm2 filesystems keyboard fsck)
# HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems fsck)
#####################################
nano /mnt/etc/fstab
nano /mnt/etc/mkinitcpio.conf

#########################
# go into arch-chroot
#########################
arch-chroot /mnt/ <<< '
locale-gen

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc

pacman -Sy
pacman -S --noconfirm lvm2 linux-firmware sudo intel-ucode

mkinitcpio -P

passwd
arch
arch

pacman -S --noconfirm gptfdisk nano htop openssh dbus avahi cronie alsa-utils networkmanager git

bootctl --path=/boot install

useradd -mg users -G wheel,storage,power -s /bin/bash markus
passwd markus
arch
arch
chage -d 0 markus

systemctl enable avahi-daemon
systemctl enable dhcpcd
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service
systemctl enable sshd
systemctl enable NetworkManager.service

pacman -S --noconfirm gnome gdm gnome-tweaks
systemctl enable gdm
'

#####################################
# manual configuration
# 1. sudoers: enable wheel
#####################################
nano /mnt/etc/sudoers

# Unmount all partitions
umount -R /mnt
swapoff -a

# Reboot into the new system, don't forget to remove the cd/usb
#reboot

#pacman -S --noconfirm virtualbox-guest-utils
#systemctl enable vboxservice
