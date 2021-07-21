#!/bin/bash

#diff pre_run_hashes.txt post_run_hashes.txt | grep "<" | grep -v ".desktop"

FILE=$1

sudo journalctl --file=/mnt/pre_run/$FILE > pre_temp
sudo journalctl --file=/mnt/post-10/$FILE > post_temp

diff pre_temp post_temp
