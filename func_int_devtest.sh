#!/bin/bash
set -e -x
ls -al
ant -Dusername=$DEVTESTSSHUSER -Dpwd=$DEVTESTSSHPWD -Dhost=$DEVTESTHOSTNAME
chmod 777 $TEST_OUTPUT_DIRECTORY
cp -a ./$TEST_OUTPUT_DIRECTORY/. ../test
ls ../test/
