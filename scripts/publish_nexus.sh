#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

unset no_proxy
export no_proxy="docker.artifactory.homedepot.com github.homedepot.com apps-np.homedepot.com sonar.homedepot.com api.run-np.homedepot.com"

#ls build/libs/

if [ ! "$VERSION" ]; then
	VERSION="latest"
fi
flow nexus upload -v $VERSION $ENVIRONMENT
