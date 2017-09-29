#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

mkdir ci_deployments

cp ../deployments-repo/* ci_deployments/ -rf

# check if VERSION is empty
if [ ! "$VERSION" ]; then
	VERSION="latest"
fi

# check if VERSION is empty
if [ "$APP_YAML" ]; then
	flow gcappengine deploy -v $VERSION -d src/main/appengine -y $APP_YAML $ENVIRONMENT
else
	flow gcappengine deploy -v $VERSION -d src/main/appengine $ENVIRONMENT
fi
