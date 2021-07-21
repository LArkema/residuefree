#!/bin/bash

# This script should be run from inside a shell launched by residuefree.sh or noecryptfs_residueFree.sh as appropraite.

# Set MODE and PATH based on which environment tests are run in.
MODE="baseline" #  | NoEcryptFSResidue | ResidueFree
PATH="./Iozone/" # | /home/$USER/KEEP_FILES/  (for both ResidueFree modes)

# Runs all iozone tests 30 times and writes the output to both a .xlsx file and copies the display output to a .txt file
# The .txt files were used for the filesystem_testing_visualization.ipynb file in the parent directory.
for i in {1..30}; do
	iozone -a -b "$PATH""$MODE"_iozone$i.xlsx | tee "$PATH""$MODE"_iozone$i.txt
done

# Files written to KEEP_FILES from inside ResidueFree were copied to the ./Iozone directory.