#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

VERSION_FROM_FILE=$(cat ../version-resource/"$VERSION_FILE_PATH")

if [[ $VERSION_FROM_FILE == v* ]]; then 
	INCREMENTED_VERSION=$VERSION_FROM_FILE
else
	INCREMENTED_VERSION=v$VERSION_FROM_FILE
fi

flow github -v $INCREMENTED_VERSION version $ENVIRONMENT 
