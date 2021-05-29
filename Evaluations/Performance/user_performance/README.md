This folder contains the data used to analyze and visualize the performance
of typical user applications. Each .sh file runs the given app's benchmark test once.
We wrapped each .sh file in a simple bash for-loop to run the test 10 times.
Each .sh file should be run from a shell inside the environment it is designed to test.
We manually edited each .txt file to break up standard and ResidueFree test results.

To measure Firefox performance, we used the Selenium Driver browser extension and the
tests included in the .side file. Since selenium only displayed timestamps to the nearest second,
we manually noted the difference in seconds and recorded that difference in firefox_times.txt.

Note: Any files we used to test file transfer, read, write, and/or processing speeds were not
necessarily downloaded from trusted web sites. All downloads and tests were done on a computer
used solely for ResidueFree development and testing - we do not recommend repeating on a primary machine.