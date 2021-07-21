#!/bin/bash

# Simple command to be run inside of ResidueFree. Writes the time outside of ResidueFree then exits.
echo -n "$(date +%s%3N) " > /home/user0/KEEP_FILES/tmp_time
