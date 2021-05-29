#Script creates a (limited) copy of root into new directory resFree
#Many error messages occur during execution. While most user-created files
#appear to be copied over, functionality impacts have not been investigated.

cd /
sudo mkdir resFree
sudo cp -R --reflink=always . resFree
