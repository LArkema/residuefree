#!/bin/bash

netstat -lx | cut -c 60- | grep -v "@" | grep -v "Path"
