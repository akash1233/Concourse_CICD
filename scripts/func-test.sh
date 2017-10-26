#!/bin/bash
set -e -x
export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070
ls -las
cd ./iom-ui/
cp -r ../../repo-cache/node_modules node_modules
npm install -g yarn
npm rebuild --silent
npm install --silent
yarn run e2e --silent
#protractor --baseUrl=$BASE_URL
chmod 777 functional_results
cp -a functional_results/. ../../tests
echo " functional test completed "
echo "done"