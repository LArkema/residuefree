#!/bin/bash

# Simple script to run the four Phoronix tests we used ten times.
# Each test required configuration input (shown below) and naming the test
# For ResidueFree benchmarks, this script should be run once inside a ResidueFree shell.
for i in {1..10}; do
	echo -n "TEST $i"
	phoronix-test-suite batch-run pts/openssl pts/ramspeed pts/apitest pts/network-loopback
done

# After each batch run, we copied the composite.xml result to ./Iozone from the path were
# Iozone stores it, and used regular expressions to rename the .xml files as we copied them
# Default result path: ~/.phoronix/test-results/$TESTNAME/composite.xml 
# When copying from ResidueFree, the path is /mnt/nhome/$USER/.phoronix ...

# IMPORTANT: Copy ResiudeFree output BEFORE exiting the session, otherwise it is treated as "residue."

# Test configuration options inside Phoronix
'''
RAMspeed SMP 3.5.0:
    pts/ramspeed-1.4.3
    Memory Test Configuration
        1: Copy
        2: Scale
        3: Add
        4: Triad
        5: Average
        6: Test All Options
        Type: 5


        1: Integer
        2: Floating Point
        3: Test All Options
        Benchmark: 3



APITest 2014-07-26:
    pts/apitest-1.1.0
    Graphics Test Configuration
        1: 800 x 600
        2: 1024 x 576
        3: 1024 x 768
        4: 1366 x 768
        5: Test All Options
        Resolution: 3


        1:  DynamicStreaming GLBufferSubData
        2:  DynamicStreaming GLMapUnsynchronized
        3:  DynamicStreaming GLMapPersistent
        4:  UntexturedObjects GLUniform
        5:  UntexturedObjects GLDrawLoop
        6:  UntexturedObjects GLMultiDrawBuffer-SDP
        7:  UntexturedObjects GLMultiDrawBuffer-NoSDP
        8:  UntexturedObjects GLBufferRange
        9:  UntexturedObjects GLBufferSubData
        10: UntexturedObjects GLBufferStorage-SDP
        11: UntexturedObjects GLBufferStorage-NoSDP
        12: UntexturedObjects GLDynamicBuffer
        13: UntexturedObjects GLMapUnsynchronized
        14: UntexturedObjects GLMapPersistent
        15: UntexturedObjects GLTexCoord
        16: TexturedQuadsProblem GLBindless
        17: TexturedQuadsProblem GLNaive
        18: TexturedQuadsProblem GLNaiveUniform
        19: TexturedQuadsProblem GLNoTex
        20: TexturedQuadsProblem GLNoTexUniform
        21: TexturedQuadsProblem GLSBTA
        22: TexturedQuadsProblem GLTextureArray
        23: Test All Options
        Test: 23
'''