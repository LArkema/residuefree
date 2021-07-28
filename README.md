# Overview
ResidueFree is a proof-of-concept implementation of residue-free computing as detailed by Logan Arkema
and Micah Sherr in [Residue-Free Computing](https://sciendo.com/de/article/10.2478/popets-2021-0076) (Proceedings on Privacy Enhancing Technologies, vol.2021, no.4, 2021, pp.389-405).

This repository provides the functionality described and evaluated in the paper. It does not represent a complete, or the most efficient, implementation of residue-free computing. Further, this repository contains the scripts and data we used to evaluate ResidueFree's forensic performance impacts.

We are releasing ResidueFree as open-source code for researchers who wish to duplicate our results and/or build on our work. This implementation has room for some direct improvements, like supporting multiple residue-free sessions simultaneously, enabling multiple applications to be launched in residue-free mode using the GUI interface, or expanding to non-Ubuntu Linux distribtions.

However, there is also room for more significant improvements, like using lower-level namespaces and containerization features instead of Docker, supproting MacOS implementations, and - through more substantive effort - supporting Windows. We are also including some code from early in the development process before we used Docker for containerization. While we aim to work on these improvements as we are able, we look forward to any contributions the communtiy provides.

### Run ResidueFree
Clone this repository, enter the "residuefree" directory, set the scripts to executable using `chmod +x` and run `sudo ./residueFree.sh -p` to launch a bash shell running inside ResidueFree. Full installation and command-line options are shown using the `-h` flag.

Dependency Note: The first time ResidueFree runs, it will ask to install Docker, Ecryptfs, and Unionfs if they are not installed already. Agreeing to install these packages will use apt to install them and all of their respective dependencies. 

## Files
[residueFree.sh](residueFree.sh) - the main script that sets up and enters a ResidueFree session, either in privacy mode (`-p`) or forensics mode (`-f`). In privacy mode, all modified files are stored in RAM, encrypted, and immediately erased when the ResidueFree session ends. In forensics mode, all modified files are seperated to a designated folder in the current filesystem for subsequent analysis. 

By default, ResidueFree launches a new bash shell, but a specific command can also be passed as a command line argument. Additional command line options are available using the `-h` flag.

[enable_GUI.sh](enable_GUI.sh) - A copy of the enable_GUI() function in residueFree.sh that creates a "Run in ResidueFree" right-click option for all desktop applications with a .desktop file in /usr/share/applications. Available as a seperate file in case a user decides to enable the GUI option after initial set-up or if the ResidueFree option is removed after an application update.

[restore_appstate.sh](restore_appstate.sh) - A small ResidueFree child program that waits for six minutes after ResidueFree exits to re-enable Ubuntu's application use tracking file (by default, Ubuntu write app usage every five minutes). 

[emergency_residue_cleanup.sh](emergency_residue_cleanup.sh) - A copy of ResidueFree's cleanup process (actually destorying the residue) that only runs if ResidueFree is killed before it can cleanup itself.

## [Old Approaches](old_approaches)
Folder contains an old version of ResidueFree and older files used to test potential components of ResidueFree before using Docker to provide namespace and containerization features. These files are not well-documented or well-written, but we are providing them for anyone who wants to work on a version of ResidueFree that does not use Docker.

# Non-code Paper Artifacts

## [Evaluations](https://github.com/LArkema/residuefree/tree/Evaluations)
This branch contains all scripts used to evaluate ResidueFree's forensic and performance impacts, as well as all performance data presented in the paper. More detailed information is available in the branch's README file. 

## Presentation
You can view [Residue-Free Computing presentation](https://www.youtube.com/watch?v=2TEMAeaxm44&list=PLWSQygNuIsPdfA8TBXlw647oHIJY21RFj&index=43) we presented at PETS, as well as the [presentation with captions](https://georgetown.box.com/s/02c9c3gtgmz8fnzkvdokio5af4b7fz1u) (though the first link's YouTube auto-captions may be better). We have also uploaded our [PETS poster](https://georgetown.box.com/s/uzfwj0wzkbg62u3dekgtlu8df2z68fbh).

## Dependencies
ResidueFree was most recently tested on the following dependency versions:
- Docker version 20.10.2, build 20.10.2-0ubuntu1~18.04.2 (`docker -v`)
- ecryptfsd (ecryptfs-utils) 111 (`ecryptfd -v`)
- unionfs-fuse version 1.0, FUSE library version 2.9.7, fusermount version 2.9.7, FUSE kernel interface version 7.19 (`unionfs -V`)

## VM
A [virtual machine](https://georgetown.box.com/s/xnlevmxnbgdc4q08lmkpkr49sw4egq98) with this repository and all dependencies installed is available for [download](https://georgetown.box.com/s/xnlevmxnbgdc4q08lmkpkr49sw4egq98). 
 - Credentials:  user0:ResidueFreeIsNeat
 - SHA256: 8E69AED437EB99A5BC272A4C8250233B2A55ED9BEA096A0164A0208497C1FBD2

## [Citation](citation.bib)
Please cite this work using the following BibTex, also in [citation.bib](citation.bib):
```
@article{ArkemaSherr+2021+389+405
author = {Logan Arkema and Micah Sherr},
doi = {doi:10.2478/popets-2021-0076},
url = {https://doi.org/10.2478/popets-2021-0076},
title = {Residue-Free Computing},
journal = {Proceedings on Privacy Enhancing Technologies},
number = {4},
volume = {2021},
year = {2021},
pages = {389--405}
}
```
