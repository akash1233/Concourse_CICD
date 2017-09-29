#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070
export JAVA_TOOL_OPTIONS="-Dhttp.proxyHost=thd-svr-proxy-qa.homedepot.com -Dhttp.proxyPort=7070"
unset no_proxy
export no_proxy="docker.artifactory.homedepot.com github.homedepot.com apps-np.homedepot.com sonar.homedepot.com api.run-np.homedepot.com"

set -e -x
echo "Printing BUILD_PIPELINE_NAME : $BUILD_PIPELINE_NAME"

if [[ -z "${token}" && -z "${QUALITYHUB_TOKEN}" ]]; then
    if [ -d ../test-results ]; then
        flow sqh post -b $SQH_BUILD_NAME -g $SQH_JOB_NAME -s $SQH_STATUS -d ../test-results -t $SQH_JOB_NAME $ENVIRONMENT
    else
        flow sqh post -b $SQH_BUILD_NAME -g $SQH_JOB_NAME -s $SQH_STATUS $ENVIRONMENT
    fi
else
    CD_STR="flow qualityhub post -S $SQH_JOB_NAME -B $SQH_BUILD_NAME -s $SQH_STATUS"

    if [ -d ../test-results ]; then
	  CD_STR="$CD_STR -d ../test-results -t $SQH_JOB_NAME"
    fi

    if [[ ! -z "${SQH_JOB_LINK}" ]]; then
        CD_STR="$CD_STR -l $SQH_JOB_LINK"
    fi

    if [[ ! -z "${SQH_JOB_DESCRIPTION}" ]]; then
        CD_STR="$CD_STR -D \"$SQH_JOB_DESCRIPTION\""
    fi
    
	CD_STR="$CD_STR $ENVIRONMENT"
    eval $CD_STR
fi

