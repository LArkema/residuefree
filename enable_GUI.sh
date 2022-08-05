#!/bin/bash

# Copy of the enable_GUI() function in ResidueFree.sh that
# users can run if they decide to enable the GUI right-click
# option after the initial ResidueFree run.


apps_dir="/usr/share/applications/"
snaps_dir="/var/lib/snapd/desktop/applications/"

DESKTOP_APPS=$(/usr/bin/find $apps_dir -name "*.desktop")
DESKTOP_SNAPS=$(/usr/bin/find $snaps_dir -name "*.desktop")

DESKTOP_ALL=( "${DESKTOP_APPS[@]}" "${DESKTOP_SNAPS[@]}" )


RES_PATH="$(pwd)/residueFree.sh"

for file in ${DESKTOP_ALL[@]}; do

	#Only execute on apps without a residue free option
	if grep -q "ResidueFree" $file; then
		echo -n ''
	else

		#Get the name of the binary clicking on the app executes
		if [[ $file == "$snaps_dir"* ]]; then
			exe=$(grep "Exec=" $file -m 1 | awk -F ".desktop" '{print $NF}' | cut -d ' ' -f 2- | cut -d'%' -f 1)
		else
			exe=$(grep "Exec=" $file -m 1 | cut -d"=" -f 2 | cut -d'%' -f 1)
		fi

		#Add Residue-Free to desktop actions, or make actions item
		if grep -q "Actions=" $file; then
                	sed -i '/^Actions=/ s/$/ResidueFree;/' $file
        	else
                	echo "Actions=ResidueFree;" >> $file
        	fi

		#Add Residue-Free Desktop Action
		echo "" >> $file
		echo "[Desktop Action ResidueFree]" >> $file
       		echo "Name=Run in ResidueFree" >> $file
        	echo "Exec=gnome-terminal -e \"bash -c 'sudo $RES_PATH $exe'\"" >> $file
		
		#Add junk then delete to refresh launcher
		echo "reset" >> $file
		sed -i '$ d' $file
	fi
done
