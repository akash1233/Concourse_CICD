#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow sqh post -b PCF -g DEPLOY-$ENVIRONMENT -s STARTED $ENVIRONMENT

mkdir ci_deployments

cp ../deployments-repo/* ci_deployments/ -rf

# check if VERSION is empty
if [ ! "$VERSION" ]; then
	VERSION="latest"
fi

if [ -f "$ENVIRONMENT_FILE" ]; then
        #if there is a environment file provided, then go and source it
      	#this is useful if you want to override a version for a file for example.
	source $ENVIRONMENT_FILE
fi

flow cf deploy -v $VERSION $ENVIRONMENT

ls -l

flow sqh post -b PCF -g DEPLOY-$ENVIRONMENT -s COMPLETED $ENVIRONMENT