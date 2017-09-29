#!/bin/bash
set -e -x
export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070
ls -las
cd ../code-repo/iom-ui/
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#apt-get update
#apt-get install -y google-chrome-stable
#echo "compiling the tsc file "
npm install -g yarn
npm install -s
yarn run e2e
#protractor --baseUrl=$BASE_URL
chmod 777 functional_results
cp -a functional_results/. ../../tests
echo " functional test completed "
echo "done"