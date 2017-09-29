#!/bin/bash

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

. /root/.virtualenvs/ci/bin/activate

pip install -r $REQUIREMENTS_TXT_FILE_PATH
pip install -e $SOURCE_FILES_DIR
pip list --format=columns

mkdir -p $TEST_OUTPUT_DIRECTORY

py.test -s -v ./src/test --junitxml=$TEST_OUTPUT_DIRECTORY/results.xml

ret_cd=$?

chmod 777 $TEST_OUTPUT_DIRECTORY

cp -a ./$TEST_OUTPUT_DIRECTORY/. ../test

deactivate

exit ${ret_cd}
