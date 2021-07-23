# Evaluations
This branch contains the results of the extensive evaluations we performed on ResidueFree for the [Residue-Free Computing paper](https://petsymposium.org/2021/files/papers/issue4/popets-2021-0076.pdf). They represent the functionality of ResidueFree as of the main repository's initial commit, and performance tests were run on a Toshiba Satellite laptop with an i3 processor and 6GB of RAM. 

## [Performance](Performance)
The performance folder contains the Jupyter Notebook Python scripts that were used to analyze and visualize (i.e. generate the graphs used in the paper) the Iozone filesystem benchmarks, Phoronix system performance benchamrks, overhead (i.e. startup and shutdown) time tests, and the user application performance tests. In addition to these scripts, the commands and/or scripts used to generate the data, as well as the data presented in the paper are in their respective sub-directories. 

## [Forensics](Forensics)
Since our forensic evaluation was conducted on the entire filesystems of two virtual machines, we are unable to include the forensic artifacts we used. However, we have included the scripts we used to isolate files that differed between the two filesystems (after they were extracted as .img files from their original VMs and made available to the VM we evaluated them in) and a detailed description of our methodology is available in the paper. 
