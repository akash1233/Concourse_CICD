#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

mvn clean package $MAVEN_OPTIONS
# Majority of the time, the destination directory will be "target"
# Use this as a default if the DIST_DIRECTORY is unset.
DIST_DIRECTORY_FINAL="${DIST_DIRECTORY:-target}"

FILE_PATTERN_TO_COPY="${FILE_PATTERN_TO_COPY:-}"

chmod 777 $DIST_DIRECTORY_FINAL

cp -r ./$DIST_DIRECTORY_FINAL/*$FILE_PATTERN_TO_COPY ../dist

ls -l
