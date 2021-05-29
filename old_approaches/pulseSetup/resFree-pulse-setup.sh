#!/bin/bash

if [ "$USER" = "root" ]
then
	PulsePID=$( ps -a -u "$SUDO_USER" | /bin/grep pulseaudio | cut -d' ' -f 1 )
else
	PulsePID=$( ps -a -u "$USER" | /bin/grep pulseaudio | cut -d' ' -f 1 )
fi
echo  "Killed $PulsePID"

kill $PulsePID
/usr/bin/pulseaudio >/dev/null 2>&1 &
sleep 2
if [ -z "$(ps -p $! | grep -P '\d+')" ]
then
	/usr/bin/pulseaudio >/dev/null 2>&1 &
	echo "Starting new pulse!"
fi
#echo $PulsePID

