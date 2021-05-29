
#Setup user's bash environment settings
/usr/bin/printenv > ~/residuefree/docker_test/user_env.sh
sed -i 's/^/export /' ~/residuefree/docker_test/user_env.sh
sed -i '1s/^/#!\/bin\/bash\n/' ~/residuefree/docker_test/user_env.sh
sed -i '/LS_COLORS/{s/LS_COLORS/"LS_COLORS/;s/$/"/;}' ~/residuefree/docker_test/user_env.sh
sed -i '/LESSCLOSE=/{s/LESS/"LESS/;s/$/"/;}' ~/residuefree/docker_test/user_env.sh
sed -i '$a\/bin\/bash' ~/residuefree/docker_test/user_env.sh

sudo docker run -it --name residue --mount type=bind,source=/bin,target=/bin \
	--mount type=bind,source=/sbin,target=/sbin \
	--mount type=bind,source=/home,target=/home \
	--mount type=bind,source=/root,target=/root \
	--mount type=bind,source=/lib,target=/lib \
	--mount type=bind,source=/lib64,target=/lib64 \
	--mount type=bind,source=/etc,target=/etc \
	--mount type=bind,source=/var,target=/var \
	--mount type=bind,source=/usr,target=/usr \
	--mount type=bind,source=/opt,target=/opt \
	--mount type=bind,source=/media,target=/media \
	--mount type=bind,source=/tmp,target=/tmp \
	--mount type=bind,source=/run,target=/run \
	--mount type=bind,source=/snap,target=/snap \
	--mount type=bind,source=/boot,target=/boot \
	--mount type=bind,source=/cdrom,target=/cdrom \
	--mount type=bind,source=/dev,target=/dev \
	--mount type=bind,source=/proc,target=/proc \
	--mount type=bind,source=/lost+found,target=/lost+found \
	--mount type=bind,source=/mnt,target=/mnt \
	--mount type=bind,source=/srv,target=/sys \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	--mount type=bind,source=/srv,target=/srv \
	--env SNAPCRAFT_SETUP_CORE=1 \
	--group-add audio --group-add sudo \
	--privileged \
	--cap-add SYS_ADMIN \
	--security-opt apparmor:unconfined \
	--security-opt seccomp:unconfined \
	residue_image /bin/bash /home/user0/residuefree/docker_test/user_env.sh
	#--mount type=bind,source=/mnt/nrun,target=/run \
	#--mount type=bind,source=/mnt/nsnap,target=/snap \
	#sudo -u user0 bash /home/user0/residuefree/docker_test/user_env.sh
	#--privileged \
	#--device=/dev/snd/ \
	#--device=/dev/video0:/dev/video0 \
	#--device=/dev/video1:/dev/video1 \
	#--mount type=bind,source=/dev,target=/dev \
	#--mount type=bind,source=/dev/video0,target=/dev/video0 \
	#--mount type=bind,source=/dev/video1,target=/dev/video1 \
	#--mount type=bind,source=/dev/snd/controlC0,target=/dev/snd/controlC0 \
	#--mount type=bind,source=/dev/snd/controlC1,target=/dev/snd/controlC1 \
	#residue_image /bin/bash

#Unmount everything
sudo /bin/umount -lf /mnt/nbin
sudo /bin/umount -lf /mnt/nsbin
sudo /bin/umount -lf /mnt/nhome
sudo /bin/umount -lf /mnt/nroot
sudo /bin/umount -lf /mnt/nlib
sudo /bin/umount -lf /mnt/nlib64
sudo /bin/umount -lf /mnt/netc
sudo /bin/umount -lf /mnt/nvar
sudo /bin/umount -lf /mnt/nusr
sudo /bin/umount -lf /mnt/nopt
sudo /bin/umount -lf /mnt/nmedia
sudo /bin/umount -lf /mnt/ntmp
sudo /bin/umount -lf /mnt/nrun
#sudo /bin/umount -lf /mnt/nsnap

sudo rm -rf /mnt/n*


sudo rm -rf /mnt/cache/*
sudo /bin/umount -lf /mnt/cache 2>/dev/null
sudo rm -rf /mnt/cache

sudo docker stop residue
sudo docker rm residue




