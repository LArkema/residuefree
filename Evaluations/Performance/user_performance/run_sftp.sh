#!/bin/bash

# Tracks the amount of time it takes SFTP to upload / read an arbitrarily large file
# (in this case the Plex Media Server debian package) to another computer on the local network

# For this test to work without any user input, the computer running the test must be able to log into
# another machine on the local network using an SSH private key. 
echo -n "$(date +"%s %3N") " >> sftp_times.txt
echo "put /home/user0/Downloads/plexmediaserver_1.20.1.3252-a78fef9a9_amd64.deb" | sftp -i ~/.ssh/id_rsa user@192.168.0.119
echo $(date +"%s %3N") >> sftp_times.txt

# Note: The version of the the Plex debian package we transferred may be a different size than the current version.