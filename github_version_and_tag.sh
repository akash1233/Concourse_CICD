#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow github version $ENVIRONMENT
