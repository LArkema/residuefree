#!/bin/bash

#Wait five minutes after residueFree exits to restore gnome shell application tracking.
#(Gnome waits five minutes after app use to write usage data to the file)

STATE_FILE="/home/$SUDO_USER/.local/share/gnome-shell/application_state" #Gnome application use stats file

#Ensure no other processes running / waiting from previous ResidueFree runs by killing them. Avoid race condition on STATE_FILE
while [[ $(/usr/bin/pgrep -f "restore_appstate.sh" | /usr/bin/wc -l) -gt 2 ]]; do
	PID=$(/usr/bin/pgrep -f "restore_appstate.sh" | /usr/bin/head -n 1)
	/bin/kill -9 $PID
done

# Re-enable gnome app usage stats (default)
/bin/su -c "/usr/bin/gsettings set org.gnome.desktop.privacy remember-app-usage true" $SUDO_USER
/bin/sleep 330 # Wait six minutes after re-enabling (when residue app use would be written) then allow writes to the file
/bin/chmod 644 $STATE_FILE

exit 0