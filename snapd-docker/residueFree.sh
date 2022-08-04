#!/bin/bash

###############################
# Author: Logan Arkema        #
# (C) 2022	              #
# License: GNU GPLv3          #
############################### 

# ResidueFree is a Proof-of-Concept Implementation of residue-free computing as detailed by Logan Arkema
# and Micah Sherr in ResidueFree (Proceedings of the Privacy Enhancing Technologies Symposium, 2021 Volume 4).

# This script provides the functionality described in that paper and was used to generate all test cases and
# evaluation data. It does not represent a complete, or the most efficient, implementation of residue-free computing.

# We are releasing this script as open-source code for researchers who wish to duplicate our results and/or build on our work.
# This implementation has more direct room for improvement, like supporting multiple residue-free sessions simultaneously,
# (relatedly) enabling multiple applications to be launched in residue-free mode using GUI options, or expanding to non-Ubuntu
# Linux distribtions.
# However, there is also room for more significant improvements, like using lower-level namespaces and containerization features
# rather than Docker, supproting MacOS implementations, and - through more substantive effort - supporting Windows. 
# While we aim to work on these improvements as we are able, we look forward to any contributions the communtiy provides. 

### FUNCTIONS ###
# Print basic help information if improper parameters are entered or -h
print_help()
{
	echo "Usage: sudo ./residueFree.sh [-h] | -p [-s SIZE] [-o KEEP_DIR] | -f [-o OUTDIR] [-z] [-m] [-D]

where:
	-h  show help text

	Privacy Mode Options
	-p  select privacy mode - default (no file changes reach disk and are destroyed after use)
	-s  specify the size of the cache in RAM for changed files (default 1 Gigabyte - privacy mode only)
	    Accepts the same arguments as tmpfs(5) -o size=bytes
	    WARNING: Some arguments may cause programs to misfunction or corrupt RAM
	-o  specify which directory kept files are saved to

	Forensic Mode Options
	-f  select forensic mode - privacy default (files changed are saved for analysis - all changed files have execute bit removed)
	-o  specify the directory where changed files are written to (default ./\"residue_free_cache_<DATE_TIME>\")
	-z  zip output files instead of leaving them in a directory tree structure
	-m  maintain empty root directories in saved cache output (deleted by default)
	-D  do not create diff file for all diffs between residue files and host system files"
	exit 1
}

## Add a right-click option to run in ResidueFree to applications stored in /usr/share/applications (default GUI application location).
# Adding a right-click option to an application does not guarantee the app will succesfully run in ResidueFree.
enable_GUI()
{
	$(pwd)/enable_GUI.sh
}

### CLEANUP PROCESS. REDUNDANCIES IN PLACE TO ENSURE THIS RUNS
cleanup()
{

#Disarm emergency cleanup process
/bin/kill -SIGUSR1 $CLEANUP_PID 2>/dev/null

#Stop and remove container (in case docker run fails)
/usr/bin/podman stop residue >/dev/null 2>&1
/usr/bin/podman rm -f residue >/dev/null 2>&1

#If user specified files to preserve, copy them to "residue files" folder on Desktop. Keep owners, remove timestamps
if [ "$(/bin/ls -A $KEEP_DIR)" ]; then
	/bin/mkdir -p $KEPT_DIR 2>/dev/null
	/bin/cp -r --backup=numbered --preserve=ownership --no-preserve=timestamps \
	$KEEP_DIR/* $KEPT_DIR
	/usr/bin/chown $SUDO_UID:$SUDO_GID $KEPT_DIR 2>/dev/null
fi


#If privacy mode, remount original FS, remove cache contents, delete encryption key, and delete cache.
if [ $MODE == "PRIVACY" ] ; then
 	/bin/umount -lf $OUTPUT 2>/dev/null #Unmount ecryptfs - all residue now irreversibly encrypted
 	/bin/umount -lf $OUTPUT 2>/dev/null #Unmount tmpfs - the virtual disk space in memory unmounted
	/bin/rm -rf $OUTPUT 2>/dev/null #Remove everything - destroy all contents of folders in virtual disk space

	#Remount filesystem with original access time settings
	if [[ $REMOUNT == "True" ]]; then
        	/bin/sed -i "/ \/ / s/$NEWOPTS/$OPTS/" /etc/fstab
        	/bin/mount -o remount,$OPTS /
	fi

#If forensic mode, change owner to user and remove execute bit on all files
else
	/bin/umount -lf $OUTPUT 2>/dev/null
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
	
	#If -D not used, create a file with the diffs of all files in output
	elif [ $DIFF == "TRUE" ]; then
		/usr/bin/diff --recursive / $OUTPUT > $OUTPUT/diffs.txt
	fi
	
	/bin/chown -R $SUDO_UID:$SUDO_GID $OUTPUT
fi

#Unmount and remove contents of all union directories
for dir in ${DIRS[@]}; do
         /bin/umount -lf /mnt/n$dir 2>/dev/null
         /bin/rm -rf /mnt/n$dir 2>/dev/null
done

#Restore updatedb.conf to no longer include ResidueFree directories
if [ -f "$UPDATEDB_CONF" ]; then
	/bin/sed -i "/PRUNEPATHS/s/$PRUNE_LAST /$PRUNE_LAST\"\n/" $UPDATEDB_CONF && /bin/sed -i "/\/mnt\/nbin \/mnt\/n/d" $UPDATEDB_CONF
fi

#Restore write access to mlocate files
if [ -d "/var/lib/mlocate" ]; then
	for file in /var/lib/mlocate/*; do
		/bin/chmod 660 $file
	done
fi

### Restore daemons and system services ###

# Runs in background to re-enable gnome state tracker after five minutes
/bin/bash $PWD/restore_appstate.sh &

#Restore pulse configuration
if [ $PULSE_CONF_EXISTS == "False" ]; then
	/bin/rm $PULSE_CONF
else
	if [ $PULSE_AUTOSPAWN_EXISTS == "False" ]; then
		/bin/sed -i '/autospawn = no/d' $PULSE_CONF
	else
		if [[ $PULSE_CHANGE_AUTOSPAWN != "NULL" ]]; then
			/bin/sed -i "s/autospawn = no/$PULSE_CHANGE_AUTOSPAWN/" $PULSE_CONF
		fi
	fi
fi

## Restart user daemons
#/bin/su -c "/usr/bin/pulseaudio --start --log-target=syslog" $SUDO_USER
#/bin/su -c "/usr/bin/gnome-keyring-daemon --daemonize --login &" $SUDO_USER
#/bin/su -c "/usr/bin/gnome-keyring-daemon --start --foreground --components=secrets &" $SUDO_USER

## Revert and restart system daemons

# Messages in kernel buffer will write to kern.log once syslog turns back on. Have them write to /dev/null.
# Do the same to syslog for good measure
/bin/mv /var/log/kern.log /var/log/kern.log.bk
/bin/mv /var/log/syslog /var/log/syslog.bk 
/bin/ln -s /dev/null /var/log/kern.log
/bin/ln -s /dev/null /var/log/syslog

/bin/systemctl start syslog.socket
/bin/systemctl start syslog.service &&

# Restore log files to their original locations afte five seconds
(/bin/sleep 5 && /bin/rm /var/log/kern.log && /bin/rm /var/log/syslog && /bin/mv /var/log/kern.log.bk /var/log/kern.log && /bin/mv /var/log/syslog.bk /var/log/syslog) &

/bin/sed -i "s/Storage=none/$JOURNAL_STORAGE/" /etc/systemd/journald.conf
/bin/systemctl restart systemd-journald.service
/bin/systemctl start apport.service

exit 0
}
## End cleanup

### END FUNCTIONS ###


### CONSTANTS AND VARIABLES ###

## Directories and Files for special interaction

#List of root's subdirectories to be mounted RO inside residue free. Does not include /dev, /proc, or /mnt.
#/dev is mounted RW to allow access to host i/o devices
#/proc is created and maintained by docker to keep processes containerized
#/mnt would create infinite file structure if mounted (potential feature addition working around union mounts).
DIRS=("bin" "cdrom" "etc" "home" "lib" "lib64" "lost+found" "media" "opt" "root" "sbin" \
       	"srv" "sys" "tmp" "usr" "var" "snap")


MODE=NULL # FORENSIC or PRIVACY mode
OUTPUT=$PWD/residue_free_cache_$(/bin/date +%m-%d-%Y_%H_%M) # Output of "residue" files (forensic mode)
ZIP=FALSE # Zip output or leave as directory tree (forensic mode)
MAINTAIN=FALSE # Keep empty high-level directories in cache output (forensic mode)
DIFF=TRUE # Create one large file for diffs between residue files and host files.
SIZE=2g # Size of tmpfs (privacy mode) - default 1 GB
FIRST_RUN=FALSE # Track if this is install run or not
REMOUNT=True # Check if main filesystem remounted with noatime option or not
KEEP_DIR=/mnt/nhome/$SUDO_USER/KEEP_FILES # Directory for files in residueFree the user wants to keep
KEPT_DIR=/home/$SUDO_USER/Documents #Directory where files the user wants to keep are put on their home system
OS_VER=$(cat /etc/*release* | grep "VERSION_ID=" | cut -d '"' -f 2) # Ubuntu operating system version

## Run cleanup after recieving interrupt or kill signals
trap cleanup SIGINT SIGTERM


### CONDITION CHECKING ###

#Check for dependencies not typically included in Ubuntu
#Check for unionfs
FIRST_RUN=FALSE
if command -v /usr/bin/unionfs >/dev/null 2>&1 ; then
	/bin/echo -n ''
else
	FIRST_RUN=TRUE
	/bin/echo "unionfs not installed. Instalation required." 1>&2
	/usr/bin/apt-get install unionfs-fuse
fi

#Check for podman
if command -v /usr/bin/podman >/dev/null 2>&1 ; then
	/bin/echo -n ''
else
	/bin/echo "Podman not installed. Instalation required." 1>&2
	/usr/bin/apt-get install podman

	#Present option to enable Podman service on boot for quicker ResidueFree launch times.
	/bin/echo ''
	/bin/echo "Do you want to enable the Podman to start when your computer powers on?"
	/bin/echo "This feature will let ResidueFree start much quicker the first time you run it after turning on your computer"
	/bin/echo "NOTE: This is not normally enabled on desktop computers. Turning this on may make it more obvious you're using ResidueFree."

	read -p "[Y/n]" yn
	case $yn in
		[Yy]* ) 
			systemctl enable podman.service
			;;
		* ) 
			/bin/echo "Not enabling Docker daemon. To enable, type \"sudo systemctl enable docker.service\" into a terminal."
			;;
	esac

fi

#Check for ecryptfs
if command -v /usr/bin/ecryptfs-add-passphrase >/dev/null 2>&1 ; then
	/bin/echo -n ''
else
	/bin/echo "ecryptfs not installed. Instalation required." 1>&2
	/usr/bin/apt-get install ecryptfs-utils
fi

#Ask if user wants GUI menu option added to all apps
if [ $FIRST_RUN == "TRUE" ]; then
	/bin/echo "Do you want to add a right-click option on all desktop applications to run the app in Residue Free?"
	/bin/echo "This feature will be added after you restart your computer. NOTE: This feature is developmental."
	read -p "[Y/n]" yn
	case $yn in
		[Yy]* ) 
			enable_GUI
			;;
		* ) 
			/bin/echo "Not enabling GUI menu options. To enable at any time, run the 'enable_GUI.sh' script"
			;;
	esac
fi

#Check that script is run as root
if [ $EUID -ne 0 ]; then
	/bin/echo "Script must be run as root"; 1>&2
	print_help
fi


#COMMAND LINE ARGUMENT PARSING

while getopts "fpo:zmDs:h" OPTION; do
	case $OPTION in
		f)
			if [ $MODE == "PRIVACY" ] ; then 
				/bin/echo "Must select -f 0R -p" 1>&2
				print_help
			fi
			MODE=FORENSIC #Output defaults to PWD/residue_free_cache_DATE_TIME
			;;
		p)
			if [ $MODE == "FORENSIC" ] ; then
				/bin/echo "Must select -f OR -p" 1>&2
				print_help
			fi
			MODE=PRIVACY
			OUTPUT=/mnt/cache
			/bin/echo "Privacy mode selected. Files saved to /home/$SUDO_USER/KEEP_FILES will be saved. ALL others will be lost."
			;;
		o)
			OUTPUT=$OPTARG
			;;
		z)
			ZIP=TRUE
			;;
		D)
			DIFF=FALSE
			;;
		m)
			MAINTAIN=TRUE
			;;
		s)
			SIZE=$OPTARG
			/bin/echo "Careful. RAM disk sizes too low may cause programs inside residue free to misfunction." 1>&2
			/bin/echo "Sizes too high may lead to system crash." 1>&2
			;;
		h)
			print_help
			;;
		*)
			print_help
			;;

	esac
done

#Get optional command to run inside residue free. If no command, run bash shell.
shift $(($OPTIND -1))
CMD=''
if [ "$#" -gt "0" ]; then
	for var in $@; do
        	CMD="$CMD $var"
	done
else
	CMD='/bin/bash'
fi

## CLI ARGUMENT LOGIC CHECKS

#Confirm an operating mode was selected
if [ $MODE == "NULL" ]; then
	/bin/echo "No mode selected. Defaulting to private mode." 1>&2
	MODE=PRIVACY
fi

if [ $MODE == "PRIVACY" ]; then
	if [ $OUTPUT != $pwd/residue_free_cache* ]; then
		KEPT_DIR=$OUTPUT
	fi
	/bin/echo "Privacy mode selected. All files will be deleted except those placed in $(echo $KEEP_DIR | sed 's/mnt\/n//'), which will be placed in $KEPT_DIR when ResidueFree exits."
	OUTPUT="/mnt/cache"
fi

#If -p used with file format options, warn user output will be deleted
if [ $MODE == "PRIVACY" ] && { [ $OUTPUT != /mnt/cache ] || [ $ZIP == "TRUE" ] || [ $MAINTAIN == "TRUE" ]; } ; then
	/bin/echo "WARNING: Privacy mode and output formating selected." 1>&2
	/bin/echo "ALL OUTPUT WILL BE PERMANENTLY DELETED WHEN RESIDUE FREE EXITS" 1>&2
	OUTPUT=/mnt/cache #Confirm that output goes to /mnt/cache
fi

#If -f used with size option, warn user it doesn't matter
if [ $MODE == "FORENSIC" ] && [ $SIZE != "1g" ] ; then
	/bin/echo "WARNING: Selected -s in forensic mode. Cache size only for privacy mode." 1>&2
fi

#Make sure OUTPUT and KEPT_DIR is properly formated (full path string)
if [[ $OUTPUT != /* ]] ; then
	OUTPUT=$PWD/$OUTPUT
fi

if [[ $OUTPUT == */ ]] ; then #(no trailing '/')
	OUTPUT=${OUTPUT%?}
fi

if [[ $KEPT_DIR != /* ]] ; then
	KEPT_DIR=$PWD/$OUTPUT
fi

if [[ $KEPT_DIR == */ ]] ; then #(no trailing '/')
	KEPT_DIR=${OUTPUT%?}
fi

## END USER-INPUT CHECKS ##


### BEGIN SYSTEM DAEMON WRANGLING ###

## Add residue file system directories to updatedb.conf so that mlocate doesn't store file names
UPDATEDB_CONF="/etc/updatedb.conf"

if [[ -f "$UPDATEDB_CONF" ]]; then
	PRUNE_BK=$(/bin/grep "PRUNEPATHS" $UPDATEDB_CONF | /usr/bin/cut -d'=' -f2 | /usr/bin/cut -d'"' -f 2)

	PRUNE_LIST=''
	for dir in ${DIRS[*]}; do
		PRUNE_LIST=$PRUNE_LIST" \/mnt\/n$dir"
	done

	#Get end of current configuration to append residue directories to and as a cut off point later.
	PRUNE_LAST=$(/bin/echo -n $PRUNE_BK | /usr/bin/rev | /usr/bin/cut -d'/' -f 1 | /usr/bin/rev)
	/bin/sed -i "/PRUNEPATHS/s/$PRUNE_LAST/$PRUNE_LAST$PRUNE_LIST/" $UPDATEDB_CONF
fi

if [[ -d "/var/lib/mlocate" ]]; then

	#And remove write perms from mlocate.db files
	for file in /var/lib/mlocate/*; do
		/bin/chmod 440 $file
	done
fi

## Stop journaling and logging while ResiudeFree runs.
JOURNAL_STORAGE=$(/bin/grep 'Storage' /etc/systemd/journald.conf)
/bin/sed -i "s/$JOURNAL_STORAGE/Storage=none/" /etc/systemd/journald.conf
/bin/systemctl restart systemd-journald.service
/bin/systemctl stop syslog.socket
/bin/systemctl stop syslog.service
/bin/systemctl stop apport.service

### END SYSTEM DAEMON WRANGLING ###


### PREP FILESYSTEMS (WHERE THE MAGIC HAPPENS) ###

#Make cache directory
/bin/mkdir -p $OUTPUT

#If privacy mode, mount output cache as an encrypted RAM disk and don't record access times on main disk.
if [ $MODE == "PRIVACY" ]; then

	#Mount the RAM disk (tmpfs)
	if ! /bin/mount -t tmpfs -o size=$SIZE tmpfs $OUTPUT; then
		/bin/echo "IMPROPER -s OPTION." 1>&2
		/bin/rmdir $OUTPUT
		exit 1
	fi

	#Generate a random 64-digit passphrase for filesystem, add it to keychain, and get keychain signature (hash)
	PASS=$(/usr/bin/base64 /dev/urandom | /usr/bin/head -c 64)
	SIG=$(/usr/bin/printf "%s" $PASS | /usr/bin/ecryptfs-add-passphrase --fnek - | /usr/bin/cut -d' ' -f 6 | \
        /usr/bin/head -n 1| /usr/bin/tr -d '[]')
	
	#Mount the encrypted FS using the random password, AES-256, and filename encryption
	/bin/mount -t ecryptfs -o \
	key=passphrase:passphrase_passwd=$PASS,no_sig_cache,ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_enable_filename=y,ecryptfs_passthrough=n,ecryptfs_enable_filename_crypto=y,ecryptfs_fnek_sig=$SIG \
	$OUTPUT $OUTPUT 1>/dev/null

	if [ $? -ne 0 ]; then
		/bin/echo "Encrypted FS failed. Exiting" 1>&2
		/bin/umount -lf $OUTPUT 2>/dev/null #Unmount encrypted fs
		/bin/umount -lf $OUTPUT 2>/dev/null #Unmount tmpfs
		/bin/rm -rf $OUTPUT
		exit 1
	fi

	#Overwrite PASS and SIG with random characters
	PASS=$(/usr/bin/base64 /dev/urandom | /usr/bin/head -c 65)
	SIG=$(/usr/bin/base64 /dev/urandom | /usr/bin/head -c 65)

	#REMOUNT MAIN FILESYSTEM TO NOT RECORD ACCESS TIMES

	#Get the current options set for the main filesystem mount
	OPTS=$(/bin/grep ' / ' /etc/fstab | /bin/grep -v "#")
	OPTS=($OPTS)
	OPTS=${OPTS[3]}

	if [[ "$OPTS" == *"noatime"* ]]; then
        	REMOUNT=False
	else
        	NEWOPTS="noatime,$OPTS"
        	/bin/sed -i "/ \/ / s/$OPTS/$NEWOPTS/" /etc/fstab
        	/bin/mount -o remount,$NEWOPTS /
        	REMOUNT=True
	fi
fi
#End privacy mode file setup

#Create cache subdirectories and directories to mount union file systems (read from OS, write to cache)
for dir in ${DIRS[@]}; do
	/bin/mkdir $OUTPUT/$dir 2>/dev/null # Residue file directories
	/bin/mkdir /mnt/n$dir 2>/dev/null # Union file directories
	/usr/bin/unionfs -o allow_other,use_ino,suid,dev,nonempty -ocow $OUTPUT/$dir=RW:/$dir=RO /mnt/n$dir 2>/dev/null
	
	#Change mounted directories back to permissions of original directories
	/bin/chmod --reference=/$dir /mnt/n$dir
	/bin/chown --reference=/$dir /mnt/n$dir
done

/bin/mkdir $OUTPUT/boot 2>/dev/null

## Bind mount necessary sockets to enable writes to OS
 /bin/mount --rbind /tmp/.X11-unix/ /mnt/ntmp/.X11-unix/
 /bin/mount --rbind /tmp/.ICE-unix/ /mnt/ntmp/.ICE-unix/
# /bin/mount --rbind /run/lock /mnt/nrun/lock
# /bin/mount --rbind /run/dbus /mnt/nrun/dbus
# /bin/mount --rbind /run/dbus/system_bus_socket /mnt/nrun/dbus/system_bus_socket
# /bin/mount --rbind /run/user/$SUDO_UID/at-spi/bus /mnt/nrun/user/$SUDO_UID/at-spi/bus
# /bin/mount --rbind /run/user/$SUDO_UID /mnt/nrun/user/$SUDO_UID
# /bin/mount --rbind /run/user/$SUDO_UID/bus /mnt/nrun/user/$SUDO_UID/bus
# /bin/mount --rbind /run/snapd.socket /mnt/nrun/snapd.socket
# /bin/mount --rbind /run/snapd-snap.socket /mnt/nrun/snapd-snap.socket
# /bin/chown -R $SUDO_UID:$SUDO_GID /mnt/nrun/user/$SUDO_UID 2>/dev/null
 /bin/chown -R $SUDO_UID:$SUDO_GID /mnt/nhome/$SUDO_USER/.cache/dconf

 
 #Create directory of files to transfer back to host.
/bin/mkdir $KEEP_DIR
/bin/chown $SUDO_UID:$SUDO_GID $KEEP_DIR

### END FILE SYSTEM PREPARATION ###
 
### WRANGLE USER DAEMONS (that write to files) ###
#Get keyring's PID
KEYRING_PID=$(/usr/bin/pgrep -f "/usr/bin/gnome-keyring-daemon" -u $SUDO_USER)

## Set the pulse configuration file to not autospawn a new processes
## (And save state to revert file back)
PULSE_CONF_EXISTS=False
PULSE_CONF="/home/$SUDO_USER/.config/pulse/client.conf"
PULSE_AUTOSPAWN_EXISTS=False
PULSE_CHANGE_AUTOSPAWN=NULL

if [ -f $PULSE_CONF ]; then
	PULSE_CONF_EXISTS=True
	if /bin/grep -q "autospawn" $PULSE_CONF; then
		PULSE_AUTOSPAWN_EXISTS=True
		if ! /bin/grep -q "autospawn = no" $PULSE_CONF; then
			PULSE_CHANGE_AUTOSPAWN=$(/bin/grep autospawn $PULSE_CONF)
			# /bin/sed -i "s/$PULSE_CHANGE_AUTOSPAWN/autospawn = no/" $PULSE_CONF
		fi
	else
		/bin/echo "autospawn = no" >> $PULSE_CONF
	fi
else
	/bin/echo "autospawn = no" > $PULSE_CONF
fi

#Kill user daemons that write to files (keyring and pulseaudio)
#/bin/su -c "/usr/bin/pulseaudio --kill" $SUDO_USER
#/bin/kill -9 $KEYRING_PID 2>/dev/null

#Disable writes to gnome's file for tracking application usage
/bin/su -c "/usr/bin/gsettings set org.gnome.desktop.privacy remember-app-usage false" $SUDO_USER
/bin/chmod 444 /home/$SUDO_USER/.local/share/gnome-shell/application_state #Disable writes to application_state

### END USER DAEMONS ###


### PREPARE DOCKER CONTAINER ###

#Setup three shell scripts that will run to initialize residue free
ENVFILE=/mnt/nhome/user_env.sh
DFILE=/mnt/nhome/user_daemons.sh #Stored in tmpfs to ensure deletion
CMDFILE=/mnt/nhome/user_command.sh #Stored in tmpfs to ensure deletion
SETUPFILE=/mnt/nroot/setup_commands.sh #Stored in tmpfs to ensure deletion

#Copy user's environment variables into a script that will import them to residue free
/usr/bin/sudo -u $SUDO_USER /usr/bin/printenv > $ENVFILE
/bin/sed -i 's/^/export /' $ENVFILE
/bin/sed -i '1s/^/#!\/bin\/bash\n/' $ENVFILE
/bin/sed -i '/LS_COLORS/{s/LS_COLORS/"LS_COLORS/;s/$/"/;}' $ENVFILE
/bin/sed -i '/LESSCLOSE=/{s/LESS/"LESS/;s/$/"/;}' $ENVFILE
/bin/sed -i '/export PATH=/d' $ENVFILE
/bin/echo "export $(grep 'PATH=' /etc/environment)" >> $ENVFILE
#/bin/echo "export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$SUDO_UID/bus" >> $ENVFILE

/bin/echo "/bin/bash /home/user_daemons.sh" >> $ENVFILE
/bin/sed -i '/-[fpozmsh]/d' $ENVFILE #Delete command line options added to the shell environment
/bin/chmod +x $ENVFILE

#Launch user daemons inside residueFree
/bin/echo "/usr/bin/gnome-keyring-daemon --daemonize --login >/dev/null 2>&1 &" >> $DFILE
/bin/echo "/usr/bin/gnome-keyring-daemon --start --foreground --components=secrets >/dev/null 2>&1 &" >> $DFILE
#/bin/echo "/usr/bin/pulseaudio --start --log-target=null" >> $DFILE
/bin/echo "/bin/bash /home/user_command.sh" >> $DFILE

#Launch user's command. Can't put at end of DFILE for processes started via GUI option
/bin/echo "#!/bin/bash" >> $CMDFILE
/bin/echo "$CMD" >> $CMDFILE

#Commands to run as root once continer is launched and stable
# /bin/echo "snap install core --edge" >> $SETUPFILE
# /bin/echo "systemctl start snapd" >> $SETUPFILE

/bin/echo "/bin/mount -t securityfs securityfs /sys/kernel/security" >> $SETUPFILE #Trick snap into thinking AppArmor installed
#/bin/echo "mount -a" >> $SETUPFILE

/bin/echo "chown $SUDO_USER:$SUDO_USER /run/user/$SUDO_UID/" >> $SETUPFILE

/bin/echo "/usr/bin/sudo -u $SUDO_USER /bin/bash /home/user_env.sh" >> $SETUPFILE
#/bin/echo "sleep 4 && systemctl status snapd" >> $SETUPFILE
#/bin/echo "/bin/bash" >> $SETUPFILE

### END CONTAINER PREP


# find /mnt/netc/systemd/system/ -not -iname "snap*" -exec rm -f {} \; 2>/dev/null

#/home/user/ResidueFree/snapd-docker/run-residue.sh acpi

#dirs=$(find /etc/ -maxdepth 1 -not -type d | cut -d '/' -f 3 2>/dev/null)
#for d in $dirs; do 
#	echo $d
#	/home/user/ResidueFree/snapd-docker/run-residue.sh $d
#	podman rm -f residue
#	echo ''
#	echo ''
#done

#rm -f /mnt/netc/fstab

#echo "# UNCONFIGURED FSTAB FOR BASE SYSTEM" > /mnt/netc/fstab
#echo "UUID=5ef49843-57bc-4760-8237-c81f47533419 /snap/               ext4    defaults" >> /mnt/netc/fstab

#sed -i '1,11!d' /mnt/netc/fstab #Keeping 1-11 has same behavior as keeping fstab. Removing 10 and 11 (i.e. boot) lets snapd run, but causes errors with libre.
#sed -i 's/\/boot\/efi/\/tmp/' /mnt/netc/fstab #Using has same behavior as normal

rm -rf /mnt/netc/acpi/




find /mnt/netc/systemd/ -iname "*.service" -not -iname "snap*" -exec rm -f {} \;

mkdir $OUTPUT/boot/efi


### RUN RESIDUEFREE ###

# Launch a detached process that cleans up ResidueFree if it is killed
/bin/bash $PWD/emergency_residue_cleanup.sh $$ $KEEP_DIR $MODE $OUTPUT $ENVFILE $JOURNAL_STORAGE &
CLEANUP_PID=$!

#Run residue free docker container.
# (Currently does not include /proc and /mnt; full mount of /dev)
# TODO: This was not written by experienced Docker engineers, room for this to be cleaned up.
 /usr/bin/podman run -it -d --name=residue --rm --log-driver=none \
	--mount type=bind,source=/mnt/nbin/,target=/bin \
	--mount type=bind,source=/dev,target=/dev \
	--mount type=bind,source=/mnt/nsbin/,target=/sbin \
	--mount type=bind,source=/mnt/nsnap,target=/snap \
	--mount type=bind,source=/mnt/nusr,target=/usr \
	--mount type=bind,source=/mnt/nlib,target=/lib \
	--mount type=bind,source=/mnt/nroot,target=/root \
	--mount type=bind,source=/mnt/nhome,target=/home \
	--mount type=bind,source=/mnt/nopt,target=/opt \
        --mount type=bind,source=/mnt/nsrv,target=/srv \
	--mount type=bind,source=/mnt/nlib64,target=/lib64 \
        --mount type=bind,source=/mnt/nlost+found,target=/lost+found \
        --mount type=bind,source=/mnt/nmedia,target=/media \
	--mount type=bind,source=/mnt/nvar,target=/var \
	--mount type=bind,source=/mnt/ntmp,target=/tmp \
	--mount type=bind,source=/mnt/nsys,target=/sys \
	--mount type=bind,source=/mnt/netc,target=/etc \
	--mount type=bind,source=$OUTPUT/boot/efi,target=/boot/efi \
	--mount type=bind,source=/run/user/1000/pulse/native,target=/run/user/1000/pulse/native \
	--privileged \
	--net=host \
	ubuntu:$OS_VER /sbin/init #/usr/bin/sudo -u $SUDO_USER /bin/bash $ENVFILE
	#--sysctl net.ipv6.conf.all.disable_ipv6=0 \ # include in options to enable openVPN. Not working with Docker update.


	#--tmpfs /boot/efi \
	#--mount type=bind,source=/mnt/nboot,target=/boot \
	
	#--mount type=bind,source=/mnt/netc,target=/etc \
	# y11y
	#--mount type=bind,source=/mnt/netc/systemd/system,target=/etc/systemd/system \
	#--mount type=bind,source=/mnt/netc/systemd/user,target=/etc/systemd/user \
	#--mount type=bind,source=/mnt/netc/pulse,target=/etc/pulse \
	#--mount type=bind,source=/mnt/netc/sudo.conf,target=/etc/sudo.conf \
	#--mount type=bind,source=/mnt/netc/sudoers,target=/etc/sudoers \
	#--mount type=bind,source=/mnt/netc/nsswitch.conf,target=/etc/nsswitch.conf \
	#--mount type=bind,source=/mnt/netc/ld.so.cache,target=/etc/ld.so.cache \
	#--mount type=bind,source=/mnt/netc/passwd,target=/etc/passwd \
	#--mount type=bind,source=/mnt/netc/gtk-3.0,target=/etc/gtk-3.0 \
	#--mount type=bind,source=/mnt/netc/xdg,target=/etc/xdg \
	#--mount type=bind,source=/mnt/netc/libreoffice,target=/etc/libreoffice \
	

	#--mount type=bind,source=/mnt/nrun,target=/run \
	#--mount type=bind,source=/mnt/nrun/user/$SUDO_UID,target=/run/user/$SUDO_UID \
	#--mount type=bind,source=/mnt/nrun/dbus,target=/run/dbus \
	#--mount type=bind,source=/mnt/nrun/user/$SUDO_UID/bus,target=/run/user/$SUDO_UID/bus \
	#--mount type=bind,source=/mnt/nrun/lock,target=/run/lock \

/usr/bin/podman exec -it residue /bin/bash /root/setup_commands.sh

# Run cleanup and exit
cleanup
