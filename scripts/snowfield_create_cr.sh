#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

flow cr create $ENVIRONMENT

git clone ../deployments-repo ../updated-git

cp ci_deployments/* ../updated-git -rf

cd ../updated-git/

git config --global user.email "nobody@concourse.ci"
git config --global user.name "Concourse"

git add .
git commit -m "Adding version number info"

ls -l