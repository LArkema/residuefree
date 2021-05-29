#!/bin/bash

#Unmount components of union filesystem and cache
sudo /bin/umount /mnt/union/tmp 2> /dev/null
sudo /bin/umount /mnt/union/proc 2> /dev/null
sudo /bin/umount /mnt/union/sys 2> /dev/null
sudo /bin/umount /mnt/union/dev/shm 2> /dev/null
sudo /bin/umount /mnt/union/dev/pts 2> /dev/null
sudo /bin/umount /mnt/union/dev 2> /dev/null
sudo /bin/umount -lf /mnt/union 2> /dev/null
sudo /bin/umount /mnt/union/run
sudo /bin/umount /mnt/union/run/user/1000/pulse
sudo /bin/umount /mnt/union/usr
sudo /bin/umount /mnt/union/home
sudo /bin/umount /mnt/union/opt
sudo /bin/umount /mnt/union/var
sudo /bin/umount /mnt/union/lib

#Delete cache contents, fill cache with random file, then delete and unmount
sudo rm -rf /mnt/cache/*
sudo swapon -a #Allow swaping so dd doesn't crash RAM
#sudo dd if=/dev/urandom of=/mnt/cache/overwrite.txt bs=1024 count=1M  
sudo rm -f /mnt/cache/overwrite.txt
sudo /bin/umount -lf /mnt/cache 2> /dev/null

#Remove directories
sudo rm -rf /mnt/union
sudo rm -rf /mnt/cache

sudo docker stop residue
sudo docker rm residue
