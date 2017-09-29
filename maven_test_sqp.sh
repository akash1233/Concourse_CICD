#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

#flow sqh post -b junit -g UNIT-TEST -s STARTED $ENVIRONMENT

mvn test

chmod 777 $TEST_OUTPUT_DIRECTORY

cp -a ./$TEST_OUTPUT_DIRECTORY/. ../test

#flow sqh post -b junit -g UNIT-TEST -s COMPLETED -d ../test -t UNIT $ENVIRONMENT

ls -l
