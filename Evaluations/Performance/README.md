The python notebooks should be run in order to generate the analysis and figures we used in the paper. Requires `jupyter-notebook` running in this directory as well as matplotlib and pandas packages installed using `pip`.
Each directory contains the test data, scripts used to generate the data, and test-specific information.

Performance tests were conducted on a Toshiba Satellite laptop running an Intel Core i3-5015U CPU @ 2.10 GHz (quad core), with 6GB of RAM and a 500 GB HDD (as we describe it in the paper, a potato). When using ResidueFree in VMs allocated even modest resources but running on higher-end hardware (i.e. i7 CPU and a Solid State Drive), we observed substantially improved performance.
