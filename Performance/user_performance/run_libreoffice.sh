#!/bin/bash

# Record the time it takes to convert a sample 1MB .odt file to a PDF five times
# using LibreOffice. While not the most accurate substitute for normal user behavior,
# it allows for the test to be run without any additional input.

# Sample file downloaded from https://file-examples.com/index.php/sample-documents-download/sample-odt-download/

echo -n "$(date +"%s %3N") " >> libre_times.txt

for i in {1..5}; do
	libreoffice --convert-to pdf /home/user0/Downloads/file-sample_1MB-$i.odt
done

rm file-sample_1MB-*.pdf
echo $(date +"%s %3N") >> libre_times.txt