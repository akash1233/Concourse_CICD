#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

mvn compile
flow sonar scan $ENVIRONMENT
