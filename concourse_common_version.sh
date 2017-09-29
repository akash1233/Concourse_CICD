#!/bin/bash

full_tag=`git -C ../ci describe --tags`
tag=${full_tag%%-[[:digit:]+]-*}

if [ -n "$tag" ] ; then
	echo "This build is using version $tag of Concourse Common"
else
	echo "The version of Concourse Common could not be determined"
fi