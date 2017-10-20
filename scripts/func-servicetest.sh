#!/bin/bash

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

ls -al

cd ../code-repo

./gradlew funcIntegrationTest -DTESTENV=${ENVIRONMENT}

chmod 777 $TEST_OUTPUT_DIRECTORY

ls -al ./$TEST_OUTPUT_DIRECTORY/

cp -a ./$TEST_OUTPUT_DIRECTORY/. ../tests

ls -l