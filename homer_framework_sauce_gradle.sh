#!/bin/bash

set -e -x

nohup sc -u $SAUCE_USER -k $SAUCE_TOKEN --se-port 4447 --proxy thd-svr-proxy-qa.homedepot.com:7070 --proxy-tunnel > /dev/null 2>&1 &

sleep 30

mvn compile exec:java -Dexec.mainClass="com.homer.runner.HomerRunner"
