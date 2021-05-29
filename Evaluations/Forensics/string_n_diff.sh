#!/bin/bash

#diff pre_run_hashes.txt post_run_hashes.txt | grep "<" | grep -v ".desktop"

FILE=$1

sudo strings /mnt/pre_run/$FILE > pre_temp
sudo strings /mnt/post_run/$FILE > post_temp

diff pre_temp post_temp