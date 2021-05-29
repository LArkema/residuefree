The three scripts in this folder were used to generate the overhead times in timing.txt

[runtime.sh](runtime.sh) was used to launch [time_residueFree.sh](time_residueFree.sh) in privacy mode with [printtime.sh](printtime.sh) passed
to it so that the modified version of ResidueFree would run, writie the time to [timing.txt](timing.txt) on run, 
write the time immediately before running docker, start a new ResidueFree session that
would run [printtime.sh](printtime.sh) (writing the time to a temporary file outside of ResidueFree), and write
the time immediately before exiting.

We used a simple bash command to append the times written by printtime inside ResidueFree to [timing.txt](timing.txt)

When generating the initial (post-boot) launch times, we used systemctl to enable and disable docker, and waited
~5 minutes (or after CPU utilization was consistently below 0.2%) after boot to run runtime.sh
