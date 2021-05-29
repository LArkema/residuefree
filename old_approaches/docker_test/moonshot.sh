#!/bin/bash

# CONSTANTS

#List of root's subdirectories to be mounted RO inside residue free. Does not include /dev, /proc, or /mnt.
#/dev is mounted RW to allow access to host i/o devices
#/proc is created and maintained by docker to keep processes containerized
#/mnt would create infinite file structure if mounted (potential feature addition working around union mounts).
DIRS=("bin" "boot" "cdrom" "etc" "home" "lib" "lib64" "lost+found" "media" "mnt" "opt" "root" "run" "sbin" \
       	"srv" "sys" "tmp" "usr" "var")

MODE=NULL # FORENSIC or PRIVACY mode
OUTPUT=$PWD/residue_free_cache_$(date +%m-%d-%Y_%R) # Output of "residue" files (forensic mode)
ZIP=False # Zip output or leave as directory tree (forensic mode)

# CONDITION CHECKING

#Check for dependencies not typically included in Ubuntu
#Check for unionfs
if command -v /usr/bin/unionfs >/dev/null 2>&1 ; then
	echo -n ''
else
	echo "unionfs not installed. Instalation required."
	/usr/bin/apt-get install unionfs-fuse
fi

#Check for docker
if command -v /usr/bin/docker >/dev/null 2>&1 ; then
	echo -n ''
else
	echo "docker not installed. Instalation required."
	/usr/bin/apt-get installa -y docker
fi


#Check that script is run as root
if [ $EUID -ne 0 ]; then
	echo "Script must be run as root";
	exit;
fi


#COMMAND LINE ARGUMENT PARSING

while getopts "fpo:" OPTION; do
	case $OPTION in
		f)
			MODE=FORENSIC
			;;
		p)
			MODE=PRIVACY
			OUTPUT=/mnt/cache
			;;
		o)
			OUTPUT=$OPTARG

	esac
done

if [ $MODE == "NULL" ]; then
	echo "Must specify forensic or privacy mode"
	#Create function to print usage information
	exit
fi

echo $OUTPUT

#Make cache directory and mount tmpfs
 /bin/mkdir $OUTPUT
 exit

#If privacy mode, mount cache as a RAM disk
if [ $MODE == "PRIVACY" ]; then
	echo "Mounting RAM disk"
 	/bin/mount -t tmpfs -o size=1024M tmpfs /mnt/cache/
fi

#Create cache subdirectories and directories to mount union file systems (read from OS, write to cache)
for dir in ${DIRS[@]}; do
         /bin/mkdir /mnt/cache/$dir
         /bin/mkdir /mnt/n$dir
  	 /usr/bin/unionfs -o allow_other,use_ino,suid,dev,nonempty -ocow /mnt/cache/$dir=RW:/$dir=RO /mnt/n$dir 2>/dev/null
	 #Change mounted directories back permissions of original directories
	 /bin/chmod --reference=/$dir /mnt/n$dir
	 /bin/chown --reference=/$dir /mnt/n$dir
done


#Bind mount necessary sockets to enable writes to OS
 /bin/mount --rbind /tmp/.X11-unix/ /mnt/ntmp/.X11-unix/
 /bin/mount --rbind /tmp/.ICE-unix/ /mnt/ntmp/.ICE-unix/
 /bin/mount --rbind /run/lock /mnt/nrun/lock
 /bin/mount --rbind /run/dbus /mnt/nrun/dbus
 /bin/mount --rbind /run/user/$SUDO_UID /mnt/nrun/user/$SUDO_UID
 /bin/chown -R $SUDO_USER:$SUDO_USER /run/user/$SUDO_UID 2>/dev/null


#Copy user's environment variables into a script that will import them to residue free
/usr/bin/printenv > ~/residuefree/docker_test/user_env.sh
/bin/sed -i 's/^/export /' ~/residuefree/docker_test/user_env.sh
/bin/sed -i '1s/^/#!\/bin\/bash\n/' ~/residuefree/docker_test/user_env.sh
/bin/sed -i '/LS_COLORS/{s/LS_COLORS/"LS_COLORS/;s/$/"/;}' ~/residuefree/docker_test/user_env.sh
/bin/sed -i '/LESSCLOSE=/{s/LESS/"LESS/;s/$/"/;}' ~/residuefree/docker_test/user_env.sh
/bin/sed -i '$a\/bin\/bash' ~/residuefree/docker_test/user_env.sh

#Run residue free docker container. Mounts cannot be looped over
# (Currently does not include /proc and /mnt; full mount of /dev)
 /usr/bin/docker run -it --name residue --rm \
	--mount type=bind,source=/mnt/nbin,target=/bin \
	--mount type=bind,source=/mnt/nboot,target=/boot \
	--mount type=bind,source=/mnt/ncdrom,target=/cdrom \
	--mount type=bind,source=/mnt/netc,target=/etc \
	--mount type=bind,source=/dev,target=/dev \
	--mount type=bind,source=/mnt/nhome,target=/home \
	--mount type=bind,source=/mnt/nlib,target=/lib \
	--mount type=bind,source=/mnt/nlib64,target=/lib64 \
	--mount type=bind,source=/mnt/nlost+found,target=/lost+found \
	--mount type=bind,source=/mnt/nmedia,target=/media \
	--mount type=bind,source=/mnt/nopt,target=/opt \
	--mount type=bind,source=/mnt/nroot,target=/root \
	--mount type=bind,source=/mnt/nrun,target=/run \
	--mount type=bind,source=/mnt/nsbin,target=/sbin \
	--mount type=bind,source=/mnt/nsrv,target=/srv \
	--mount type=bind,source=/mnt/nsys,target=/sys \
	--mount type=bind,source=/mnt/ntmp,target=/tmp \
	--mount type=bind,source=/mnt/nusr,target=/usr \
	--mount type=bind,source=/mnt/nvar,target=/var \
	--privileged \
	residue_image sudo -u $SUDO_USER /bin/bash /home/user0/residuefree/docker_test/user_env.sh


#Unmount and remove contents of all union directories
for dir in ${DIRS[@]}; do
         /bin/umount -lf /mnt/n$dir 2>/dev/null
         /bin/rm -rf /mnt/n$dir 2>/dev/null
done

#Remove cache contents, overwrite with junk, and delete cache.
 /bin/rm -rf /mnt/cache/* 2>/dev/null
 /bin/umount -lf /mnt/cache 2>/dev/null
 /bin/rm -rf /mnt/cache 2>/dev/null

#Stop and remove container
 /usr/bin/docker stop residue 2>/dev/null
 /usr/bin/docker rm residue 2>/dev/null
