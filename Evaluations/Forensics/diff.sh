#!/bin/sh

# Change the root directories between post_run vs. post-10, pre_run vs. post_run,
# and pre_run vs. post-10, as appropriate
sudo diff /mnt/post_run/$1 /mnt/post-10/$1