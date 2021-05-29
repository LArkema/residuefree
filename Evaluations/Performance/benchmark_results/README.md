The [bulk_iozone.sh](bulk_iozone.sh) and [bulk_phoronix.sh](bulk_phoronix.sh) files in this directory show the command-line input
used to generate Iozone and Phoronix benchamrk data, respectively. Each file contains more
information about how it was used to generate the data in their respective sub-folders, and
each file should be run from a shell inside the environment it is measuring. The [noecryptfs_residueFree.sh](noecryptfs_residueFree.sh)
file is a modified version of ResidueFree.sh that does not encrypt the residue stored in RAM.
