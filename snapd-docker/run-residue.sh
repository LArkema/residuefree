#!/bin/bash

SUBDIR=$1

/usr/bin/podman run -it -d --name=residue --rm --log-driver=none \
        --mount type=bind,source=/mnt/nbin/,target=/bin \
        --mount type=bind,source=/mnt/nsbin/,target=/sbin \
        --mount type=bind,source=/mnt/nusr/,target=/usr \
        --mount type=bind,source=/mnt/nsnap,target=/snap \
        --mount type=bind,source=/mnt/nlib,target=/lib \
        --mount type=bind,source=/dev,target=/dev \
        --mount type=bind,source=/mnt/nroot,target=/root \
        --mount type=bind,source=/mnt/nhome,target=/home \
        --mount type=bind,source=/mnt/nopt,target=/opt \
        --mount type=bind,source=/mnt/nsrv,target=/srv \
        --mount type=bind,source=/mnt/nlib64,target=/lib64 \
        --mount type=bind,source=/mnt/nlost+found,target=/lost+found \
        --mount type=bind,source=/mnt/nmedia,target=/media \
        --mount type=bind,source=/mnt/nvar,target=/var \
        --mount type=bind,source=/mnt/nsys,target=/sys \
        --mount type=bind,source=/mnt/ntmp,target=/tmp \
        --mount type=bind,source=/mnt/netc/systemd/system,target=/etc/systemd/system \
        --mount type=bind,source=/mnt/netc/systemd/user,target=/etc/systemd/user \
        --mount type=bind,source=/mnt/netc/pulse,target=/etc/pulse \
        --mount type=bind,source=/mnt/netc/sudo.conf,target=/etc/sudo.conf \
        --mount type=bind,source=/mnt/netc/sudoers,target=/etc/sudoers \
        --mount type=bind,source=/mnt/netc/nsswitch.conf,target=/etc/nsswitch.conf \
        --mount type=bind,source=/mnt/netc/ld.so.cache,target=/etc/ld.so.cache \
        --mount type=bind,source=/mnt/netc/passwd,target=/etc/passwd \
        --mount type=bind,source=/mnt/netc/gtk-3.0,target=/etc/gtk-3.0 \
        --mount type=bind,source=/mnt/netc/xdg,target=/etc/xdg \
        --mount type=bind,source=/mnt/netc/libreoffice,target=/etc/libreoffice \
        --mount type=bind,source=/mnt/netc/$SUBDIR,target=/etc/$SUBDIR \
	--privileged \
        --net=host \
        ubuntu:22.04 /sbin/init         #/usr/bin/sudo -u $SUDO_USER /bin/bash $ENVFILE
        #--sysctl net.ipv6.conf.all.disable_ipv6=0 \ # include in options to enable openVPN. Not working with Docker update.


/usr/bin/podman exec -it residue /bin/bash /root/setup_commands.sh
