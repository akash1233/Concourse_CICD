#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow zipit -z $ZIP_NAME -c ../zipitdirectory $ENVIRONMENT