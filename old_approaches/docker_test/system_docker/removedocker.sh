#!/bin/bash

sudo umount -lf /mnt/cache 2>/dev/null
sudo umount -lf /mnt/n* 2>/dev/null

sudo rm -rf /mnt/cache
sudo rm -rf /mnt/n*
