#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x


echo "Deployment repo content"
ls -lrt ../deploy-repo

echo "installing cf cli"

wget -qO- 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' | tar -zxf - -C /usr/local/bin

echo "deploying apps to ZONE ${ENVIRONMENT}"

#TODO change the CF_API URL to make it consistent
cf login -a ${CF_API} -u ${DEPLOYMENT_USER} -p ${DEPLOYMENT_PWD} -o ${CF_ORG} -s ${CF_SPACE}

#echo "start db2Svc service update"
#cf cups db2Svc -p '{"uri": "'${DB2_FULL_URL}'"}' || cf uups db2Svc -p '{"uri": "'${DB2_FULL_URL}'"}'
#echo "end db2Svc service update"
#
#echo "start dcmSvc service update"
#cf cups dcmSvc -p '{"url": "'${TERADATA_FULL_URL}'"}' || cf uups dcmSvc -p '{"url": "'${TERADATA_FULL_URL}'"}'
#echo "end dcmSvc service update"
#
#echo "start orcaSvc service update"
#cf cups orcaSvc -p '{"jdbcUrl": "'${ORACLE_FULL_URL}'"}' || cf uups orcaSvc -p '{"jdbcUrl": "'${ORACLE_FULL_URL}'"}'
#echo "end orcaSvc service update"


echo "**************************************"
echo "deploy started  for iom ui"
echo "**************************************"

cd ../code-repo/iom-ui

ls -ltr

# TODO move the build of UI project to gradle build

echo "building the project"

npm install -s && npm install -g yarn

yarn run build:${BUILD_TARGET}


# Call the bg deploy ui
bg_deploy_ui

echo "**************************************"
echo "deploy completed  for iom ui"
echo "**************************************"



# Deployment for approval ui
echo "**************************************"
echo "deploy started  for iom approval ui"
echo "**************************************"

cd ../iom-approval-ui



ls -ltr

echo "building the project"

npm install -s && npm install -g yarn

yarn run build:${BUILD_TARGET}


# Call the bg deploy ui
bg_deploy_ui

echo "**************************************"
echo "deploy completed  for iom approval ui"
echo "**************************************"


echo "**************************************"
echo "deploy started  for iom-ui-service"
echo "**************************************"

cd ../iom-ui-services
bg_deploy ../../deploy-repo/iom-ui-services.jar

echo "**************************************"
echo "deploy completed for iom-ui-service"
echo "**************************************"

echo "**************************************"
echo "deploy started  for iom-xfer-service"
echo "**************************************"
cd ../iom-xfer-services
bg_deploy ../../deploy-repo/iom-xfer-services.jar

echo "**************************************"
echo "deploy completed for iom-xfer-service"
echo "**************************************"

echo "**************************************"
echo "deploy started  for iom-scheduler"
echo "**************************************"
cd ../iom-scheduler
bg_deploy ../../deploy-repo/iom-scheduler.jar

echo "**************************************"
echo "deploy completed for iom-scheduler"
echo "**************************************"

echo "**************************************"
echo "deploy started  for iom-approval-service"
echo "**************************************"
cd ../iom-approval-service
bg_deploy ../../deploy-repo/iom-approval-service.jar

echo "******************************************"
echo "deploy completed  for iom-approval-service"
echo "*****************************************"

echo "*****************************************************************************"
echo "Start list all the application in current space"
cf apps
echo "Complited list all the application in current space"

echo "********************************************************* ${ENVIRONMENT} done"



# BG Setup
bg_deploy_ui() {
APP_NAME=$(awk '/name:/ {print $NF}' ${ENVIRONMENT}.manifest.yml)  # grab the app name from the manifest.yml file
APP_NAME_BLUE=${APP_NAME}-BLUE
APP_NAME_GREEN=${APP_NAME}-GREEN
CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"

# get the app name from manifest file
ROUTE_NAME=$(awk '/host:/ {print $NF}' ${ENVIRONMENT}.manifest.yml)  # grab the route name from the manifest.yml file

# get the route name
if [[ -z ${ROUTE_NAME} ]]; then
    echo "host configuration in manifest.yml does not exist, so defaulting to app name: '${APP_NAME}'"
    ROUTE_NAME=${APP_NAME}
fi

ROUTE_NAME=${APP_NAME}.${CF_DOMAIN}

CFAPPS=$(cf apps)

echo "cf apps results:\n${CFAPPS}"
echo "ROUTE_NAME: ${ROUTE_NAME}"
APP_NAME_ACTIVE=$(cf apps | awk -v routename=${ROUTE_NAME} '$0 ~ routename {print $1}')
echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"

if [[ ! -z ${APP_NAME_ACTIVE} ]]; then
    echo "${APP_NAME_ACTIVE} is the active app with route '${ROUTE_NAME}'"
    if [ "${APP_NAME_ACTIVE}" == "${APP_NAME_GREEN}" ]; then
        APP_NAME_TARGET=${APP_NAME_BLUE}
    else
        APP_NAME_TARGET=${APP_NAME_GREEN}
    fi
else
    echo "no app is active with the route '${ROUTE_NAME}'"
    APP_NAME_TARGET=${APP_NAME_GREEN}   # default to green
fi

echo "target app name: '${APP_NAME_TARGET}'"

echo "cf push application"

cf push ${APP_NAME_TARGET} -f ${ENVIRONMENT}.manifest.yml

echo "cf logout"
cf logout

}


# BG Setup for services
bg_deploy() {
PATH=$1
APP_NAME=$(awk '/name:/ {print $NF}' ${ENVIRONMENT}.manifest.yml)  # grab the app name from the manifest.yml file
APP_NAME_BLUE=${APP_NAME}-BLUE
APP_NAME_GREEN=${APP_NAME}-GREEN
CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"

# get the app name from manifest file
ROUTE_NAME=$(awk '/host:/ {print $NF}' ${ENVIRONMENT}.manifest.yml)  # grab the route name from the manifest.yml file

# get the route name
if [[ -z ${ROUTE_NAME} ]]; then
    echo "host configuration in manifest.yml does not exist, so defaulting to app name: '${APP_NAME}'"
    ROUTE_NAME=${APP_NAME}
fi

ROUTE_NAME=${APP_NAME}.${CF_DOMAIN}

CFAPPS=$(cf apps)

echo "cf apps results:\n${CFAPPS}"
echo "ROUTE_NAME: ${ROUTE_NAME}"
APP_NAME_ACTIVE=$(cf apps | awk -v routename=${ROUTE_NAME} '$0 ~ routename {print $1}')
echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"

if [[ ! -z ${APP_NAME_ACTIVE} ]]; then
    echo "${APP_NAME_ACTIVE} is the active app with route '${ROUTE_NAME}'"
    if [ "${APP_NAME_ACTIVE}" == "${APP_NAME_GREEN}" ]; then
        APP_NAME_TARGET=${APP_NAME_BLUE}
    else
        APP_NAME_TARGET=${APP_NAME_GREEN}
    fi
else
    echo "no app is active with the route '${ROUTE_NAME}'"
    APP_NAME_TARGET=${APP_NAME_GREEN}   # default to green
fi

echo "target app name: '${APP_NAME_TARGET}'"

echo "cf push application"

cf push ${APP_NAME_TARGET} -f ${ENVIRONMENT}.manifest.yml -p ${PATH}
echo "cf logout"
cf logout
}

