#!/bin/bash

# Tracks the amount of time it takes to download / write a 1 GB file
# served over HTTP from a machine on the same local network, where
# 192.168.0.119:8000 is an arbitrary computer hosting a simple web server
# using python3 -m http.server 

# Test file downloaded from https://fastest.fish/test-files 

echo -n "$(date +%s%3N) " >> wget_times.txt
wget http://192.168.0.119:8000/1GB.bin
echo "$(date +%s%3N)" >> wget_times.txt

rm 1GB.bin