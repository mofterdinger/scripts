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
lvcreate --name swap -L 16G $VOL_GRP
lvcreate --name root -L 25G $VOL_GRP
lvcreate --name home -l 100%FREE $VOL_GRP
lvdisplay

#########################
# format logical volumes
#########################
mkfs.fat -F 32 -n EFIBOOT /dev/sda1
mkfs.ext4 -F -L lv_root /dev/vg1/root
mkfs.ext4 -F -L lv_home /dev/vg1/home
mkswap -L lv_swap /dev/vg1/swap

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
# manual configuration
# 1. fstab: add option discard
# 2. mkinitcpio.conf: add hook lvm2
# 3. locale.gen: uncomment languages
#####################################
nano /mnt/etc/fstab
nano /mnt/etc/mkinitcpio.conf
nano /mnt/etc/locale.gen

#########################
# go into arch-chroot
#########################
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

pacman -S --noconfirm openssh acpid dbus avahi cups cronie
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable dhcpcd
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service
systemctl enable sshd

pacman -S --noconfirm xorg-server xorg-xinit xorg-drivers ttf-dejavu

pacman -S --noconfirm gnome gdm 
systemctl enable gdm
'

echo '
[Unit]
Description=XVNC Server

[Socket]
ListenStream=5900
Accept=yes

[Install]
WantedBy=sockets.target
' > /mnt/etc/systemd/system/xvnc.socket

echo '
[Unit]
Description=XVNC Per-Connection Daemon

[Service]
ExecStart=-/usr/bin/Xvnc -inetd -query localhost -geometry 1920x1080 -once -SecurityTypes=None -localhost
User=nobody
StandardInput=socket
StandardError=syslog
' > /etc/systemd/system/xvnc@.service

#####################################
# manual configuration
# 1. sudoers: enable wheel
# 2. gdm: enable xdmcp
#    [xdmcp]
#    Enable=true
#    Port=177
#####################################
nano /mnt/etc/sudoers
nano /mnt/etc/gdm/custom.conf

# Unmount all partitions
umount -R /mnt
swapoff -a

# Reboot into the new system, don't forget to remove the cd/usb
reboot

#pacman -S --noconfirm plasma-meta kde-applications-meta sddm sddm-kcm
#systemctl enable sddm

#pacman -S --noconfirm virtualbox-guest-utils
#systemctl enable vboxservice
