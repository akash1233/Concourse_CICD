#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

mkdir ci_deployments

cp ../deployments-repo/* ci_deployments/ -rf

flow cr close $ENVIRONMENT