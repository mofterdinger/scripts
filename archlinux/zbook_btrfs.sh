#!/bin/bash
set -x

#############################
# variables
#############################
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

pacstrap /mnt base linux linux-lts linux-firmware intel-ucode btrfs-progs
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

echo "title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /intel-ucode.img
initrd  /initramfs-linux-lts.img
options root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-lts.conf

echo "title   Arch Linux Fallback
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=LABEL=lv_root rw resume=LABEL=lv_swap" > /mnt/boot/loader/entries/arch-fallback.conf

#####################################
# manual configuration
# 1. fstab: add option discard
# 2. mkinitcpio.conf:
# MODULES=(i915 intel_agp vfat crc32c-intel)
# BINARIES=("/usr/bin/btrfsck")
# HOOKS=(base systemd autodetect modconf block sd-vconsole encrypt btrfs filesystems keyboard fsck)
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
pacman -S --noconfirm lvm2 linux-firmware sudo intel-ucode efibootmgr

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

pacman -S --noconfirm gnome gdm gnome-tweaks firefox vlc handbrake keepassxc
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

