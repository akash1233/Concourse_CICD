#!/bin/bash

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

ls -al


cd ../code-repo

cd $PERF_PROJECT

./gradlew assemble --stacktrace

./gradlew jmRun --debug

./gradlew jmReport --debug

# convert jmeter xml test results to junit

wget "https://maven.artifactory.homedepot.com/artifactory/libs-release/org/apache/jmeter-junit/0.1/jmeter-junit-0.1.jar"

#chmod 777 $TEST_OUTPUT_DIRECTORY
#
#ls -al ./$TEST_OUTPUT_DIRECTORY/

#java -jar jmeter-junit-0.1.jar --input $TEST_OUTPUT_DIRECTORY/*.xml --output ../tests/junit.xml
#
#ls -al

#cp -a ./$TEST_OUTPUT_DIRECTORY/. ../tests
