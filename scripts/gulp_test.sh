#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e
set -x

export TERM=xterm-256color
export NODE_ENV=$ENVIRONMENT
pwd

mv ../repo-cache/node_modules node_modules

# if [ -d ../repo-cache/global_node_modules ]; then
#     cp -R ../repo-cache/global_node_modules/* /usr/lib/node_modules
# fi

if [ -f bower.json ]; then
    echo "Bower detected" >&2
    if [ -f .bowerrc ]; then
        echo "Found bower config file" >&2
        CUSTOM_BOWER_DIRECTORY=$(grep "directory" .bowerrc | cut -d '"'  -f4)
        if [ ${#CUSTOM_BOWER_DIRECTORY} -gt 0 ]; then
            echo "Found custom bower directory $CUSTOM_BOWER_DIRECTORY" >&2
            mkdir -p $CUSTOM_BOWER_DIRECTORY
            mv ../repo-cache/$CUSTOM_BOWER_DIRECTORY/* $CUSTOM_BOWER_DIRECTORY
        else
            echo "No custom bower directory specified.  Looking for dependencies in bower_components" >&2
            mkdir -p bower_components
            mv ../repo-cache/bower_components/* bower_components
        fi
    else
        echo "No bower config file detected.  Looking for dependencies in browser_components." >&2
        mkdir -p bower_components
        mv ../repo-cache/bower_components/* bower_components
    fi

    npm install -g bower-art-resolver
    bower install --allow-root
fi

npm rebuild
npm install


gulp test

chmod 777 $TEST_OUTPUT_DIRECTORY
cp -a ./$TEST_OUTPUT_DIRECTORY/. ../test

ls -l
