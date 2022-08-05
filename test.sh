#!/bin/bash

#Small temp file to test small code chunks

VERSION=$(cat /etc/*release* | grep "VERSION_ID=" | cut -d '"' -f 2)

echo $VERSION
