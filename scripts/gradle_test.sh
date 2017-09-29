#!/bin/bash

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

echo " inside test ${projectname}"
pwd 

ls -lrt


pwd

ls -lrt

./gradlew test



chmod 777 $TEST_OUTPUT_DIRECTORY

cp -av ./$TEST_OUTPUT_DIRECTORY/. ../test



cd ./$TEST_OUTPUT_DIRECTORY/

ls -lrt

cd test

cd ../../../

pwd

cd ../test

pwd

ls -lrt

ls -lrts

ls -l
