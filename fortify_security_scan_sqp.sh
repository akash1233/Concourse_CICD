#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow sqh post -b fortify -g SECURITY-SCAN -s STARTED $ENVIRONMENT

flow fortify scan $ENVIRONMENT

flow sqh post -b fortify -g SECURITY-SCAN -s COMPLETED $ENVIRONMENT