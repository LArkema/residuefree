# Overview
ResidueFree is a Proof-of-Concept Implementation of residue-free computing as detailed by Logan Arkema
and Micah Sherr in ResidueFree (Proceedings of the Privacy Enhancing Technologies Symposium, 2021 Volume 4, full citation forthcoming).

This repository provides the functionality described in that paper and was used to generate all test cases and evaluation data. It does not represent a complete, or the most efficient, implementation of residue-free computing. Further, this repository contains the scripts and performance data we used to evaluate ResidueFree's privacy-preserving effectiveness and performance impacts.

We are releasing ResidueFree as open-source code for researchers who wish to duplicate our results and/or build on our work. This implementation has more direct room for improvement, like supporting multiple residue-free sessions simultaneously, (relatedly) enabling multiple applications to be launched in residue-free mode using GUI options, or expanding to non-Ubuntu
Linux distribtions.

However, there is also room for more significant improvements, like using lower-level namespaces and containerization features
rather than Docker, supproting MacOS implementations, and - through more substantive effort - supporting Windows.  While we aim to work on these improvements as we are able, we look forward to any contributions the communtiy provides.

## Files
[residueFree.sh](https://github.com/LArkema/residuefree/blob/main/residueFree.sh) - the main script that sets up and enters a ResidueFree session, either in privacy mode (`-p`) or forensics mode (`-f`). In privacy mode, all modified files are stored in RAM, encrypted, and immediately erased when the ResidueFree session ends. In forensics mode, all modified files are seperated to a designated folder in the current filesystem for subsequent evaluation. 

By default, ResidueFree launches a new bash shell, but a specific command can also be passed as a command line argument. Additional command line options are available using the `-h` flag.

[enable_GUI.sh](https://github.com/LArkema/residuefree/blob/main/enable_GUI.sh) - A copy of the enable_GUI() function in residueFree.sh that creates a "Run in ResidueFree" right-click option for all desktop applications with a .desktop file in /usr/share/applications. Available as a seperate file in case a user decides to enable the GUI option after initial set-up or if the ResidueFree option is removed after an application update.

[restore_appstate.sh](https://github.com/LArkema/residuefree/blob/main/restore_appstate.sh) - A small ResidueFree child program that waits for six minutes after ResidueFree exits to re-enable Ubuntu's application use tracking file (by default, Ubuntu write app usage every five minutes). 

[emergency_residue_cleanup.sh](https://github.com/LArkema/residuefree/blob/main/emergency_residue_cleanup.sh) - A copy of ResidueFree's cleanup process (actually destorying the residue) that only runs if ResidueFree is killed before it can cleanup itself.

## [Evaluations](https://github.com/LArkema/residuefree/blob/main/Evaluations)
Folder contains all scripts used to evaluate ResidueFree's forensic and performance impacts, as well as all performance data presented in the paper. More detailed information is available in the folder's README file. 

## [Old Approaches](https://github.com/LArkema/residuefree/blob/main/old_approaches)
Folder contains an old version of ResidueFree and older files used to test potential components of ResidueFree before using Docker to provide namespace and containerization features. These files are not well-documented or well-written, but we are providing them for anyone who wants to work on a version of ResidueFree that does not use Docker.
