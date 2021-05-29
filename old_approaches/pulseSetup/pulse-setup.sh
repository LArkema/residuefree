#!/bin/bash

#/usr/bin/timeout 1 /usr/bin/pacmd >/dev/null 2>&1

#sudo chroot --userspec=$USER /mnt/union /usr/bin/timeout 1 /usr/bin/pacmd >/dev/null 2>&1 

#PULSEBASE=$(ls /home/$USER/.config/pulse/ | grep default-sink | cut -d'-' -f 1)

#TMPDIR=$(readlink /mnt/union/home/$USER/.config/pulse/$PULSEBASE-runtime)

#/bin/cp /run/user/$UID/pulse/pid /mnt/union/$TMPDIR/pid

#socat -s UNIX-LISTEN:/mnt/union/$TMPDIR/cli UNIX-CLIENT:/run/user/$UID/pulse/cli &   
#socat -s UNIX-LISTEN:/mnt/union/$TMPDIR/native UNIX-CLIENT:/run/user/$UID/pulse/native &

sudo chroot --userspec=$USER /mnt/union /bin/bash /home/$USER/residuefree/pulseSetup/resFree-pulse-setup.sh \ 
	>/dev/null 2>&1

#sleep 1

#sudo chroot --userspec=$USER /mnt/union /usr/bin/timeout 1 /usr/bin/pacmd >/dev/null 2>&1 

# -t10000
#,keepalive,ignoreeof,end-close &
