#!/bin/bash
###############GLOBAL VARIABLES###############
DISK = "sda"
STAGE3-URL = ""
###############GLOBAL VARIABLES###############
echo "RUN THIS AS ROOT FROM LIVE CD OR PXE BOOT!"
echo "Gentoo Install Script - by greenman aka. ccutter - version 1.0"
echo "Review the man himself for updates and imessage is prefered. =)"
echo 'press any keys...'
###############BEGIN###############
mkfs.ext2 /dev/$DISK1
mkfs.ext4 /dev/$DISK3
mkswap /dev/$DISK2
swapon /dev/$DISK2
echo "Mounting $disk. Please press CTRL-C now to stop."
echo "sleeping 5 seconds..." && sleep 8
mount /dev/$DISK3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/$DISK1 /mnt/gentoo/boot
cd /mnt/gentoo
curl -O $STAGE3-URL
tar xvjpf stage3-*.tar.bz2
rm -f stage3-*.tar.bz2
mount -t proc none /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/resolv.conf
######CHROOOOOOTING INTO THIS######
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"
echo 'GENTOO_MIRRORS=""' >> /etc/portage/make.conf
mkdir /usr/portage
emerge-webrsync
###CONFIGURING
cp /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" > /etc/timezone
#mirrorselect -s3 -b10 -o -D >> /etc/portage/make.conf
###PREPARE KERNEL BUILD
emerge gentoo-sources
emerge genkernel
genkernel all
ls -la /boot && echo "Setting up LILO. Press any key to continue..."
read return
emerge lilo
######lilo.conf######
##find better echo method
##get kernel filename from /boot automatically
echo 'image=/boot/kernel-genkernel-x86_64-3.7.10-gentoo-r1' >> /etc/lilo.conf
echo '  label=gentoo' >> /etc/lilo.conf
echo '  read-only' >> /etc/lilo.conf
echo '  append="real_root=/dev/$DISK3"' >> /etc/lilo.conf
echo '  initrd=/boot/initramfs-genkernel-x86_64-3.7.10-gentoo-r1' >> /etc/lilo.conf
/sbin/lilo
##CONFIGURING
emerge dhcpcd
rc-update add sshd default
##FINISHING UP HERE
cd
umount /mnt/gentoo/{boot,proc,sys,dev}
reboot
###############END###############