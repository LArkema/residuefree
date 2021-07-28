This directory contains details on the tests we ran to measure ResidueFree's performance, the data from those tests, and the scripts we used to generate the analysis and graphs we presented in the [paper](https://sciendo.com/de/article/10.2478/popets-2021-0076). 

[Benchmark Results](benchmark_results) contains the commands we used to generate the Iozone and Phoronix benchmark results and the results of those benchmark tests. Data from both benchmarks is analyzed in [filesystem_testing_visualization.ipynb](filesystem_testing_visualization.ipynb), which generates figures [3 / File Operations](Figures/Files.pdf); and [Phoronix_Result_Visualization.ipynb](Phoronix_Result_Visualization.ipynb), which generates figures [4 / Loopback Speeds](Figures/Loopback.pdf), [5 / OpenSSL Speeds](Figures/OpenSSL.pdf), [6 / Graphics Speeds](Figures/API.pdf), and [7 / RAM Speeds](Figures/RamSpeed.pdf).

[Overhead Times](overhead_times) contains the modified version of ResidueFree and wrapper-scripts used to time ResidueFree's startup and shutdown times, with the startup time broken down between the time Docker takes to initialize the container and everything else. Those times are analyzed in [overhead_visualization.ipynb](overhead_visualization.ipynb) and generate [figure 8 / Overhead Times](Figures/Overhead.pdf).

Finally, [User Performance](user_performance) contains the brief scripts that timed psuedo-normal user activity on common applications and the resulting times, which are analyzed in [User_App_Tests.ipynb](User_App_Tests.ipynb) to generate [figure 9 / User Application Tests](Figures/UserApps.pdf)

More detailed information about each test is available in its respective sub-directory.

The cells in each python notebook should be run in order to generate the analysis and figures we used in the paper. They require `jupyter-notebook` to be running in this directory as well as matplotlib and pandas packages to be installed using `pip`.

Performance tests were conducted on a Toshiba Satellite laptop running an Intel Core i3-5015U CPU @ 2.10 GHz (quad core), with 6GB of RAM and a 500 GB HDD (as we describe it in the paper, a potato). When using ResidueFree in VMs allocated even modest resources but running on higher-end hardware (i.e. i7 CPU and a Solid State Drive), we observed substantially improved performance.
