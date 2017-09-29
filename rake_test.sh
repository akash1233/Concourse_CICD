#!/bin/bash

export https_proxy=http://thd-svr-proxy-qa.homedepot.com:7070

set -e -x

bundle exec rake spec:javascripts #TODO change this to run rake
