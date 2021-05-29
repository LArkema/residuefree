#!/bin/bash

#Disable swapping
#sudo swapoff -a

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
    	#sudo /bin/mount -t tmpfs tmp /mnt/union/tmp 2> /dev/null
	sudo /bin/mount --bind /tmp/.X11-unix /mnt/union/tmp/.X11-unix
	sudo /bin/mount --bind /tmp/.ICE-unix /mnt/union/tmp/.ICE-unix
fi
if [ -z "$(mount | grep -w /mnt/union/run)" ]; then
	#sudo /bin/mount --rbind /run /mnt/union/run
	sudo /bin/mount --rbind /run/dbus /mnt/union/run/dbus 2> /dev/null
	sudo /bin/mount --rbind /run/user/$UID/ /mnt/union/run/user/$UID/
fi
if [ -z "$(mount | grep -w /mnt/union/var)" ]; then
	echo ""
	#sudo /bin/mount --rbind /var /mnt/union/var 2> /dev/null
fi


#mount all the things
#sudo /bin/mount --rbind /bin /mnt/union/bin
#sudo /bin/mount --rbind /usr /mnt/union/usr
#sudo /bin/mount --rbind /home /mnt/union/home
#sudo /bin/mount --rbind /opt /mnt/union/opt
#sudo /bin/mount --rbind /sbin /mnt/union/sbin
#sudo /bin/mount --rbind /lib /mnt/union/lib

sudo docker run -it --name residue --mount type=bind,source=/mnt/union,target=/mnt/union residue_image /bin/bash


#Launch new pulseaudio daemon within sandbox
#sudo chroot --userspec=$USER /mnt/union /bin/bash /home/$USER/residuefree/pulseSetup/resFree-pulse-setup.sh \ 
#	>/dev/null 2>&1

#cd /mnt/union
#sudo strace -v -t -s 128 -e trace=%ipc -f -o /home/blackbox/residuefree/resFree_ipc1_16_20 \
#	sudo chroot . \
       	#--userspec=$USER .

#sudo /bin/rm -rf /tmp/pulse-*
bash /home/$USER/docker_test/removeUnion.sh

