#!/bin/bash
set -x

#############################
# variables
#############################
PHY_VOL=/dev/sda2
VOL_GRP=vg1
hostname="archlinux"

#############################
# remove volume group
#############################
lvremove -f /dev/$VOL_GRP
vgremove -f $VOL_GRP

#############################
# unmount current partitions
#############################
umount /dev/sda1
umount /dev/sda2
umount /dev/vg1/root
umount /dev/vg1/home
swapoff /dev/vg1/swap

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
lvcreate --name root -L30G $VOL_GRP
lvcreate --name swap -L16G $VOL_GRP
lvcreate --name home -l100%FREE $VOL_GRP
lvdisplay

#########################
# format logical volumes
#########################
mkfs.fat -F 32 -n EFIBOOT /dev/sda1
mkfs.ext4 -F -L lv_arch /dev/vg1/root
mkfs.ext4 -F -L lv_home /dev/vg1/home
mkswap -L lv_swap /dev/vg1/swap

#########################
# mount logical volumes
#########################
mount -L lv_arch /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount -L EFIBOOT /mnt/boot
mount -L lv_home /mnt/home
swapon -L lv_swap

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel intel-ucode
genfstab -p /mnt > /mnt/etc/fstab

echo "$hostname" > /mnt/etc/hostname
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf

nano /mnt/etc/mkinitcpio.conf

arch-chroot /mnt/ <<< '
locale-gen

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

pacman -Sy

mkinitcpio -p linux

passwd
arch
arch

pacman -S --noconfirm efibootmgr dosfstools gptfdisk grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug

mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -g users -G wheel -s /bin/bash markus
passwd markus
arch
arch

pacman -S --noconfirm aping cpid dbus avahi cups cronie

systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable dhcpcd
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service

pacman -S --noconfirm xorg-server xorg-xinit xorg-drivers ttf-dejavu

pacman -S gnome gnome-extra
systemctl enable gdm

exit
'

# Unmount all partitions
umount -R /mnt
swapoff -a

# Reboot into the new system, don't forget to remove the cd/usb
reboot

#pacman -S --noconfirm plasma-meta kde-applications-meta sddm sddm-kcm
#systemctl enable sddm

#pacman -S --noconfirm virtualbox-guest-utils
#systemctl enable vboxservice
