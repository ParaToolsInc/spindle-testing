#!/bin/bash

set -eux

flux alloc --nodes=4
cd $HOME/Spindle-build/testsuite
./runTests

