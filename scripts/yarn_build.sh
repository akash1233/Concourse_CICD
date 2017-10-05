#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"
set -e -x
npm install -g yarn

buildcopy iom-ui
buildcopy iom-approval-ui

buildcopy(){
cd ./$1
mv ../../repo-cache/node_modules node_modules
npm rebuild
npm install
yarn run build:${BUILD_TARGET}
chmod 777 $DIST_DIRECTORY
cp -r ./$DIST_DIRECTORY/* ../dist/$1/
ls -lrt
}
