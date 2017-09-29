#!/bin/bash
set -e -x

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070
export JAVA_TOOL_OPTIONS="-Dhttp.proxyHost=thd-svr-proxy-qa.homedepot.com -Dhttp.proxyPort=7070"
unset no_proxy
export no_proxy="docker.artifactory.homedepot.com github.homedepot.com apps-np.homedepot.com sonar.homedepot.com api.run-np.homedepot.com"

flow qhjar post -S $SQH_JOB_NAME -B $SQH_BUILD_NAME -s STARTED -T $TOKEN $ENVIRONMENT

cd ../test-code-repo/

ant -Dusername=$DEVTESTSSHUSER -Dpwd=$DEVTESTSSHPWD -Dhost=$DEVTESTHOSTNAME -Dbuildno=na -Denv=$DEVTESTENV

ls -al

chmod 777 $TEST_OUTPUT_DIRECTORY

cp -r $TEST_OUTPUT_DIRECTORY/*.xml ../test/

cd ../code-repo

flow qhjar post -S $SQH_JOB_NAME -B $SQH_BUILD_NAME -s COMPLETED -T $TOKEN -d ../test -t DEVTEST $ENVIRONMENT
