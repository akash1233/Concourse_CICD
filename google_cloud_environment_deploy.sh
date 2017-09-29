#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

mkdir ci_deployments
cp ../deployments-repo/* ci_deployments/ -rf

#cp ../flow-repo/src/main/python/ /ci/ -rf
#cp ../flow-repo/src/main/python/* /ci/ -rf

#pip install -r /ci/requirements.txt
#export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python3.4:/usr/local/lib/python3.4/dist-packages:/usr/local/lib/python3.4/site-packages"

unset no_proxy
export no_proxy="docker.artifactory.homedepot.com github.homedepot.com apps-np.homedepot.com sonar.homedepot.com api.run-np.homedepot.com"
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
#

# check if VERSION is empty
if [ ! "$VERSION" ]; then
	VERSION="latest"
fi

if [ -f "$ENVIRONMENT_FILE" ]; then
	source $ENVIRONMENT_FILE
fi

flow gce create -v $VERSION $ENVIRONMENT
