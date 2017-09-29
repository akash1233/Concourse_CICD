#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

./gradlew test
flow sonar scan $ENVIRONMENT
