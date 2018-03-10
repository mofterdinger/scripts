#!/bin/bash

hostname="archlinux"
pasword="arch"

umount /dev/sda1
umount /dev/sda2
umount /dev/sda3
swapoff /dev/sda4

mkfs.fat -F 32 -n EFIBOOT /dev/sda1
mkfs.ext4 -L p_arch /dev/sda2
mkfs.ext4 -L p_home /dev/sda3
mkswap -L p_swap /dev/sda4

mount -L p_arch /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount -L EFIBOOT /mnt/boot
mount -L p_home /mnt/home
swapon -L p_swap

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel intel-ucode
genfstab -p /mnt > /mnt/etc/fstab

echo "$hostname" > /mnt/etc/hostname
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf

arch-chroot /mnt/ 

locale-gen

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

pacman -Sy

mkinitcpio -p linux

passwd
black6sun
black6sun

pacman -S --noconfirm efibootmgr dosfstools gptfdisk grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug

mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -g users -s /bin/bash markus
passwd markus
black6sun
black6sun

pacman -S --noconfirm aping cpid dbus avahi cups cronie

systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable dhcpcd
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service

pacman -S --noconfirm xorg-server xorg-xinit xorg-drivers ttf-dejavu

pacman -S --noconfirm plasma-meta kde-applications-meta sddm sddm-kcm
systemctl enable sddm

pacman -S --noconfirm virtualbox-guest-utils
systemctl enable vboxservice

