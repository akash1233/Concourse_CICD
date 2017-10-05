#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"
set -e -x
npm install -g yarn


buildcopy(){
cd ./$1
cp -r ../../repo-cache/node_modules node_modules
npm rebuild
npm install
yarn run build:${BUILD_TARGET}
chmod 777 $DIST_DIRECTORY
mkdir -p ../dist/$1/
cp -r ./$DIST_DIRECTORY/* ../dist/$1/
ls -lrt ../dist/$1/
}

buildcopy iom-ui
cd ..
buildcopy iom-approval-ui


