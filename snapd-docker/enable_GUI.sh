#!/bin/bash

# Copy of the enable_GUI() function in ResidueFree.sh that
# users can run if they decide to enable the GUI right-click
# option after the initial ResidueFree run.

DESKTOP_APPS=$(find /usr/share/applications -name "*.desktop")
RES_PATH="$(pwd)/residueFree.sh"

for file in ${DESKTOP_APPS[@]}; do

	#Only execute on apps without a residue free option
	if grep -q "ResidueFree" $file; then
		echo -n ''
	else

		#Get the name of the binary clicking on the app executes
		exe=$(grep "Exec=" $file -m 1 | cut -d"=" -f 2 | cut -d'%' -f 1)

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
        	echo "Exec=gnome-terminal -e \"bash -c 'sudo $RES_PATH -p $exe'\"" >> $file
		
		#Add junk then delete to refresh launcher
		echo "reset" >> $file
		sed -i '$ d' $file
	fi
done
