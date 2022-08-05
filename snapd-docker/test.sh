#!/bin/bash

#Small temp file to test small code chunks

mkdir -p ./test-etc/

cp -r /etc/systemd/ ./test-etc/

find ./test-etc/systemd/ -not -iname "snap*" -exec rm -f {} \;


