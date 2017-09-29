#!/bin/bash
#after incrementing th version, the new version will be exportd into a file at
#location $VERSION_OUTPUT_FILE
source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x
VERSION_OUTPUT_FILE=${VERSION_OUTPUT_FILE:-../version/version.txt}
mkdir -p `dirname $VERSION_OUTPUT_FILE`
flow github -o $VERSION_OUTPUT_FILE version $ENVIRONMENT
