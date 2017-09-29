#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

#./gradlew assemble

cf login -a ${CF_API} -u ${DEPLOYMENT_USER} -p ${DEPLOYMENT_PWD} -o ${CF_ORG} -s ${CF_SPACE} --skip-ssl-validation

ls -lrt ../deploy-repo

ls -lrt
if [[ -z "${UI_ONLY_DEPLOY}" ]]; then
    cf push -f ./iom-approval-service/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-approval-service.jar
    cf push -f ./iom-xfer-services/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-xfer-services.jar
    cf push -f ./iom-ui-services/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-ui-services.jar
    cf push -f ./iom-scheduler/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-scheduler.jar
else
    cf push -f ${ENVIRONMENT}.manifest.yml 
fi    
# mkdir ci_deployments

# cp ../deployments-repo/* ci_deployments/ -rf

# # check if VERSION is empty
# if [ ! "$VERSION" ]; then
# 	VERSION="latest"
# fi

# if [ -f "$ENVIRONMENT_FILE" ]; then
#         #if there is a environment file provided, then go and source it
# 	#this is useful if you want to override a version for a file for example.
# 	source $ENVIRONMENT_FILE
# fi

# flow cf deploy -v $VERSION $ENVIRONMENT

# ls -l
