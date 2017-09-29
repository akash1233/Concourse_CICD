#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

flow sqh post -b junit -g UNIT-TEST -s STARTED $ENVIRONMENT

./gradlew test

chmod 777 $TEST_OUTPUT_DIRECTORY

cp -r ./$TEST_OUTPUT_DIRECTORY ../test

flow sqh post -b junit -g UNIT-TEST -s COMPLETED -d ../test/test-results -t UNIT $ENVIRONMENT

ls -l
