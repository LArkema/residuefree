#!/bin/bash

DIRS=("sbin" "bin" "lib" "usr" "var" "home")

sudo mkdir /mnt/cache
sudo mount -t tmpfs -o size=1024M tmpfs /mnt/cache

#Create cache directories, mount directories, and mount union directories for all subdirectories
for dir in ${DIRS[@]}; do
	sudo mkdir -p /mnt/cache/$dir
	sudo mkdir -p /mnt/n$dir
	sudo unionfs -o allow_other,use_ino,suid,dev,nonempty -ocow /mnt/cache/$dir=RW:/$dir=RO /mnt/n$dir
done

sudo mkdir /mnt/cache/etc/
sudo cp /etc/passwd /mnt/cache/etc/passwd
sudo cp /etc/shadow /mnt/cache/etc/shadow

#Run docker with mounted subdirectories
sudo docker run -it --rm --privileged --cap-add SYS_ADMIN --mount type=bind,source=/mnt/nsbin,target=/sbin \
       	--mount type=bind,source=/mnt/nbin,target=/bin \
       	--mount type=bind,source=/mnt/nlib,target=/lib \
       	--mount type=bind,source=/mnt/nusr,target=/usr \
       	--mount type=bind,source=/mnt/nvar,target=/var \
       	--mount type=bind,source=/mnt/nhome,target=/home \
	--mount type=bind,source=/mnt/cache/etc/passwd,target=/etc/passwd \
	--mount type=bind,source=/mnt/cache/etc/shadow,target=/etc/shadow \
       	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	mysysd /lib/systemd/systemd
       	#--mount type=bind,source=/mnt/nsys/fs/cgroup,target=/sys/fs/cgroup \
