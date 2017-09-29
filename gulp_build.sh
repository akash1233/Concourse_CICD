#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x


mv ../repo-cache/node_modules iom-ui/node_modules

cd iom-ui

npm rebuild
npm install

npm run build:$BUILD_ENV


mkdir -p output-artifacts/dist
mkdir -p output-artifacts/server

cp -r ./dist ./output-artifacts/dist
cp -r ./server ./output-artifacts/server

cp .npmrc ./output-artifacts/
cp $MANIFEST_FILE ./output-artifacts/

cp -r ./output-artifacts/* ../../dist

cd ../dist
ls -l
