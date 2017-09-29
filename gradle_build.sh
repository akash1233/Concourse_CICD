#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

./gradlew assemble --stacktrace

chmod 777 $DIST_DIRECTORY

cp -r ./$DIST_DIRECTORY/* ../dist

if [ -f "pom.xml" ]; then
  cp pom.xml ../dist
fi

ls -l
