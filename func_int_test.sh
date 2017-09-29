#!/bin/bash

set -e -x

echo "protractor tests started ................."
protractor --version

#export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

#mkdir -p $TEST_OUTPUT_DIRECTORY
#touch $TEST_OUTPUT_DIRECTORY/test-output.txt

cd src/test/functional
npm install
protractor protractor.conf.js

cp *.xml ../../../../test

#chmod 777 $TEST_OUTPUT_DIRECTORY
#cp -r ./$TEST_OUTPUT_DIRECTORY ../test

ls -al
