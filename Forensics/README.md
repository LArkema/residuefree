# Overview
This folder describes the steps we used to *analyze* the filesystems for an Ubuntu VM after being idle, after running ResidueFree, and ten minutes after running ResidueFree. The steps we used to generate these filesystem artifacts are described in detail in the [paper](https://sciendo.com/de/article/10.2478/popets-2021-0076) (Section 7.1: Forensic Evaluation).

# Steps and Commands
1. We conducted these tests on Ubuntu 18.04 VMs using the iso downloaded from [Ubuntu](https://releases.ubuntu.com/18.04/) and VMWare Player
2. After using the Virtual Machines, we copied the virtual hard disks as .img files using `VBoxManage.exe clonehd --format RAW source.vdi destination.img`
3. We used a seperate VM to analyze these images, and used a [shared folder](https://docs.vmware.com/en/VMware-Workstation-Pro/16.0/com.vmware.ws.using.doc/GUID-AB5C80FE-9B8A-4899-8186-3DB8201B1758.html) to make the .img files available to this VM
4. Mounted the filesystems inside the VM with `sudo mount -o noatime,nodiratime,offset=1048576 /mnt/hgfs/Forensic\ Evals/Template.img /mnt/pre_run/`. The offset value was the block where the boot partition ended and the filesystem partition began on the .img files (calculated using `fdisk -l`). We mounted the filesystems as /mnt/pre_run/, /mnt/post_run, and /mnt/post-10 for the baseline VM, ResidueFree VM, and 10 minutes after exiting ResidueFree, respecitvely.
5. Generated hashes for every file with `find /mnt/$MODE/ -type f -exec sha256sum {} \; | tee $MODE_hashes.txt`
6. Identified the files that differed between all three filesystems (i.e. three different sets of differences) using `diff $MODE1_hashes.txt $MODE2_hashes.txt | grep "<" | grep -v ".desktop"` (.desktop files installed by default are numerous and differed by a small timestamp).
7. Analyzed the differences between readable files that differed by passing the filename to [diff.sh](diff.sh) 
8. For journal files, analyzed the differences by passing the filename to [journal_ctl_diff.sh](journal_ctl_diff.sh).
9. For binary files, analyzed the differences by passing the filename to [string_n_diff.sh](string_n_diff.sh).
10. For files present in one filesystem but not another, reviewed them using `strings` and basic terminal utilities (e.g. `cat`, `less`, and/or `grep`)

The files that differed after running ResidueFree are listed in [different_filex.txt](different_files.txt). Based on our analysis of these files, we were unable to identify any information about the apps run in ResidueFree other than the fact that ResidueFree was run. 
