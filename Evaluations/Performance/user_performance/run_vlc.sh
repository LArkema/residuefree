#!/bin/bash

# The amount of time it takes to process and watch a 24 second video using VLC.
# Video downloaded from https://mars.nasa.gov/mars2020/multimedia/videos/?v=465

# This script was run without using the "%3N" option in date to record microseconds. 
# Recommend using in future tests to allow for more fine-grained results. 
echo -n "$(date +%s) " >> vlc_times.txt
vlc file:///home/user0/Downloads/PIA24332_R2.mp4 -f
echo $(date +%s) >> vlc_times.txt
