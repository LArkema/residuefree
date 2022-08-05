#!/bin/bash

DESKTOP_APPS=$(/usr/bin/find /usr/share/applications -name "*.desktop")
DESKTOP_SNAPS=$(/usr/bin/find /snap/ -name "*.desktop")

DESKTOP_ALL=( "${DESKTOP_APPS[@]}" "${DESKTOP_SNAPS[@]}" )

file="/var/lib/snapd/desktop/applications/firefox_firefox.desktop"
#for file in ${DESKTOP_SNAPS[@]}; do
	 #Get the name of the binary clicking on the app executes
                exe=$(grep "Exec=" $file -m 1 | cut -d"=" -f 2- | cut -d'%' -f 1)

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

	
#done
