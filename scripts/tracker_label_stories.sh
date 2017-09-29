#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow tracker label-release $ENVIRONMENT
