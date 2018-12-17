#!/bin/bash
set -x

#############################
# variables
#############################
PHY_VOL=/dev/sda2
VOL_GRP=vg1
HOSTNAME="archlinux"
KEYMAP=mac-euro

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

#########################
# create physical volume
#########################
pvcreate $PHY_VOL
pvdisplay

######################
# create volume group
######################
vgcreate $VOL_GRP $PHY_VOL
vgdisplay

#########################
# create logical volumes
#########################
lvcreate --name swap -L 16G $VOL_GRP
lvcreate --name root -L 25G $VOL_GRP
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

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel intel-ucode
genfstab -p /mnt > /mnt/etc/fstab

echo $HOSTNAME > /mnt/etc/hostname
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf

echo KEYMAP=$KEYMAP > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf

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
echo "title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch.conf

echo "title   Arch Linux Fallback
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-fallback.conf

#####################################
# manual configuration
# 1. fstab: add option discard
# 2. mkinitcpio.conf:
# HOOKS=(base systemd autodetect modconf block sd-vconsole sd-lvm2 filesystems keyboard fsck)
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

mkinitcpio -p linux

passwd
arch
arch

pacman -S --noconfirm efibootmgr gptfdisk openssh dbus avahi cups cronie alsa-utils intel-ucode networkmanager

bootctl --path=/boot install

useradd -mg users -G wheel,storage,power -s /bin/bash markus
passwd markus
arch
arch
chage -d 0 markus

systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable dhcpcd
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service
systemctl enable sshd
systemctl enable NetworkManager.service

pacman -S --noconfirm xorg-server xorg-xinit xorg-drivers ttf-dejavu

pacman -S --noconfirm gnome gdm gnome-tweaks firefox htop vlc handbrake keepassxc
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

#pacman -S --noconfirm plasma-meta kde-applications-meta sddm sddm-kcm
#systemctl enable sddm

#pacman -S --noconfirm virtualbox-guest-utils
#systemctl enable vboxservice
