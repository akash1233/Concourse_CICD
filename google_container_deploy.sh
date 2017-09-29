#!/usr/bin/env bash
unset no_proxy
export no_proxy="maven.artifactory.homedepot.com docker.artifactory.homedepot.com github.homedepot.com apps-np.homedepot.com sonar.homedepot.com api.run-np.homedepot.com"

source "${BASH_SOURCE%/*}/flow-env.sh"

# check if VERSION is empty
if [ ! "$VERSION" ]; then
	VERSION="latest"
fi

if [ -f "$ENVIRONMENT_FILE" ]; then
	source $ENVIRONMENT_FILE
fi

flow gke deploy -v $VERSION $ENVIRONMENT
