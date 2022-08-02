#!/bin/bash

####################################################################
### This script runs in the background of a residue free session ###
### If ResidueFree unexpectedly exits, this runs an emergency    ###
### cleanup process. Not a perfect cleanup process, but eliminates #
### residue. SHOULD NOT RUN UNDER MOST TO ALL CIRCUMSTANCES      ###
####################################################################

# Kill this cleanup script if expected signal recieved from ResidueFree.sh
disarm()
{
	#echo "signal exiting"
	exit 0
}

KEEP_DIR=$2
MODE=$3
OUTPUT=$4
ENVFILE=$5
JOURNAL_STORAGE=$6

PULSE_CONF="/home/$SUDO_USER/.config/pulse/client.conf"
UPDATEDB_CONF="/etc/updatedb.conf"
MAINTAIN="False"
ZIP="False"
DIRS=("bin" "boot" "cdrom" "etc" "home" "lib" "lib64" "lost+found" "media" "opt" "root" "run" "sbin" \
       	"srv" "sys" "tmp" "usr" "var")


cleanup()
{

/bin/echo "EMERGENCY CLEANUP. /etc/fstab, /etc/updatedb.conf, and pulse config file may not revert properly."

#Stop and remove container (in case docker run fails)
/usr/bin/docker stop residue >/dev/null 2>&1
/usr/bin/docker rm residue >/dev/null 2>&1

#If user specified files to preserve, copy them to "residue files" folder on Desktop. Keep owners, remove timestamps
if [ "$(/bin/ls -A $KEEP_DIR)" ]; then
	/bin/mkdir /home/$SUDO_USER/Desktop/residue\ files 2>/dev/null;
	/bin/cp -r --backup=numbered --preserve=ownership --no-preserve=timestamps \
	$KEEP_DIR/* /home/$SUDO_USER/Desktop/residue\ files
fi


#If privacy mode, remount original FS remove cache contents, overwrite with junk, and delete cache.
if [ $MODE == "PRIVACY" ] ; then
 	/bin/umount -lf $OUTPUT 2>/dev/null #Unmount ecryptfs
 	/bin/umount -lf $OUTPUT 2>/dev/null #Unmount tmpfs
	/bin/rm -rf $OUTPUT 2>/dev/null #Remove everything

#If forensic mode, change owner to user and remove execute bit on all files
else
	/bin/umount -lf $OUTPUT 2>/dev/null
	/bin/chown -R $SUDO_UID:$SUDO_GID $OUTPUT
	/usr/bin/find $OUTPUT -type f -exec /bin/chmod -x {} \;
	
	#Remove subdirectories w/o written files, unless -m used
	if [ $MAINTAIN == "FALSE" ] ; then
		for dir in ${DIRS[@]}; do
			/bin/rmdir $OUTPUT/$dir 2>/dev/null
		done
	fi
	#If -z used, convert OUTPUT to a zip archive
	if [ $ZIP == "TRUE" ] ; then
		/usr/bin/zip -r $OUTPUT.zip $OUTPUT >/dev/null
		/bin/rm -rf $OUTPUT 2>/dev/null
		/bin/chown $SUDO_USER:$SUDO_USER $OUTPUT.zip
	fi
fi

#Remove user_env
/bin/rm -f $ENVFILE

#Unmount and remove contents of all union directories
for dir in ${DIRS[@]}; do
         /bin/umount -lf /mnt/n$dir 2>/dev/null
         /bin/rm -rf /mnt/n$dir 2>/dev/null
done

#Restore updatedb.conf to no longer include ResidueFree directories
#/bin/sed -i "/PRUNEPATHS/s/$PRUNE_LAST /$PRUNE_LAST\"\n/" $UPDATEDB_CONF && /bin/sed -i "/\/mnt\/nbin \/mnt\/n/d" $UPDATEDB_CONF

#Restore write access to mlocate files
for file in /var/lib/mlocate/*; do
	/bin/chmod 660 $file
done

### Restore daemons and system services ###

# Runs in background to re-enable gnome state tracker after five minutes
/bin/bash ./restore_appstate.sh &

/bin/rm $PULSE_CONF

## Restart user daemons
/bin/su -c "/usr/bin/pulseaudio --start --log-target=syslog" $SUDO_USER
/bin/su -c "/usr/bin/gnome-keyring-daemon --daemonize --login &" $SUDO_USER
/bin/su -c "/usr/bin/gnome-keyring-daemon --start --foreground --components=secrets &" $SUDO_USER

## Revert and restart system daemons
/bin/sed -i "s/Storage=none/$JOURNAL_STORAGE/" /etc/systemd/journald.conf
/bin/systemctl restart systemd-journald.service

# Messages in kernel buffer will write to kern.log once syslog turns back on. Have them write to /dev/null.
/bin/mv /var/log/kern.log /var/log/kern.log.bk
/bin/ln -s /dev/null /var/log/kern.log

/bin/systemctl start syslog.socket
/bin/systemctl start syslog.service &&

/bin/rm /var/log/kern.log
/bin/mv /var/log/kern.log.bk /var/log/kern.log

exit 1
}
## End Cleanup

# If program recieves the "disarm" signal from ResidueFree, it does not run.
trap disarm USR1

# Otherwise it waits for ResidueFree to die then runs cleanup
tail --pid=$1 -f /dev/null && echo "emergency cleanup" && cleanup
