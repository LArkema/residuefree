#!/bin/bash

#Disable swapping
sudo swapoff -a

#make necessary directories
sudo mkdir -p /mnt/cache
sudo mkdir /mnt/union

#Mount RAM fs for cache writes
sudo mount -t tmpfs -o size=1024M tmpfs /mnt/cache/

# Script from https://www.howtoforge.com/safe_mirror_unionfs_chroot
# also, some good stuff from http://forum.tinycorelinux.net/index.php?topic=13392.0

# mount temporary filesystems
#if [ -z "$(mount -t unionfs | grep -w /mnt/union )" ]; then
sudo unionfs -o allow_other,use_ino,suid,dev,nonempty -ocow /mnt/cache=RW:/=RO /mnt/union
	
#fi
#if [ -n "$(mount -t unionfs | grep -w /mnt/union )" ]; then
    # basic system mounts
if [ -z "$(mount | grep -w /mnt/union/dev)" ]; then
    sudo /bin/mount --bind /dev /mnt/union/dev 2> /dev/null
fi
    
if [ -z "$(mount -t devpts | grep -w /mnt/union/dev/pts)" ]; then
    sudo /bin/mount -t devpts devpts /mnt/union/dev/pts 2> /dev/null
fi
if [ -z "$(mount -t tmpfs | grep -w /mnt/union/dev/shm)" ]; then
    sudo /bin/mount -t tmpfs shm /mnt/union/dev/shm 2> /dev/null
fi
    
if [ -z "$(mount -t sysfs | grep -w /mnt/union/sys)" ]; then
    sudo /bin/mount -t sysfs sysfs /mnt/union/sys 2> /dev/null
fi

if [ -z "$(mount -t proc | grep -w /mnt/union/proc)" ]; then
    sudo /bin/mount -t proc proc /mnt/union/proc 2> /dev/null
fi
if [ -z "$(mount | grep -w /mnt/union/tmp)" ]; then
    sudo /bin/mount --bind /tmp /mnt/union/tmp 2> /dev/null
fi
if [ -z "$(mount | grep -w /mnt/union/run)" ]; then
	sudo /bin/mount --bind /run/dbus /mnt/union/run/dbus 2> /dev/null
	sudo /bin/mount --bind /run/user/$UID/pulse /mnt/union/run/user/$UID/pulse
	sudo /bin/mount --bind /run/snapd.socket /mnt/union/run/snapd.socket
fi
#if [ -z "$(mount | grep -w /mnt/union/var)" ]; then
#	echo ""
#	sudo /bin/mount --bind /var /mnt/union/var 2> /dev/null
#fi

#Launch new pulseaudio daemon within sandbox
sudo chroot --userspec=$USER /mnt/union /bin/bash /home/$USER/residuefree/pulseSetup/resFree-pulse-setup.sh \ 
	>/dev/null 2>&1

cd /mnt/union
#sudo strace -v -t -s 128 -e trace=%ipc -f -o /home/blackbox/residuefree/resFree_ipc1_16_20 \
	sudo chroot . \
       	#--userspec=$USER .

sudo /bin/rm -rf /tmp/pulse-*
bash /home/$USER/residuefree/removeUnion.sh

