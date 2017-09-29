#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow sqh post -b selenium -g FUNCTIONAL-TEST -s STARTED $ENVIRONMENT

flow sqh post -b selenium -g FUNCTIONAL-TEST -s COMPLETED -d ../test -t FUNCTIONAL $ENVIRONMENT