#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x


echo "Deployment repo content"
ls -lrt ../deploy-repo



echo "Deployment repo content"
ls -lrt ../deploy-repo

ls -lrt ../../



installcfcli() {
    echo "installing cf cli"
    wget -qO- 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' | tar -zxf - -C /usr/local/bin
    echo "deploying apps to ZONE ${ENVIRONMENT}"
}

logintoconcourse() {
    echo " logging to concourse with following api ${CF_API} and org ${CF_ORG} and  space ${CF_SPACE}"
    cf login -a "${CF_API}" -u "${DEPLOYMENT_USER}" -p "${DEPLOYMENT_PWD}" -o "${CF_ORG}" -s "${CF_SPACE}"
}



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
MANIFESTFILE=$1
APP_NAME=$2
ROUTE_NAME=$3
JARPATH=$4
CF_DOMAIN=$5

#Define the app types

BLUE=${APP_NAME}
GREEN="${BLUE}-B"

#Specify the full route
ROUTE_NAME=${ROUTE_NAME}.apps-${CF_DOMAIN}

# create the GREEN application
cf push $GREEN -f ${MANIFESTFILE} -p ${JARPATH} | tee pushoutput.txt


# ensure it starts by grepping the text 'requested state: started'
if grep -Fxq "requested state: started" pushoutput.txt; then
echo "requested text found- Deploy completed"
else
echo "Error Deploying!! requested state: started not found"
exit 125
fi
#ROUTE Mapping
#cf map-route $GREEN ${ROUTE_NAME}

##Stop the app
##cf stop $BLUE
## add the GREEN application to each BLUE route to be load-balanced
## TODO this output parsing seems a bit fragile...find a way to use more structured output
#cf routes | tail -n +4 | grep $BLUE | awk '{print $3" -n "$2}' | xargs -n 3 cf map-route $GREEN

# cleanup
# TODO consider 'stop'-ing the BLUE instead of deleting it, so that depedencies are cached for next time
timestamp=$(date +%s)
cf rename $BLUE $BLUE${timestamp}
cf rename $GREEN $BLUE
cf rename$BLUE${timestamp} $BLUE
cf delete-route $CF_DOMAIN -n $GREEN -f
cf stop $BLUE

finally
echo "Blue Green Deploy Completed"

}


deployui() {
    # Deployment for iom ui
    echo "deploy started  for iom ui"
    cd ../code-repo/iom-ui
    ls -ltr
    mkdir -p dist  && chmod 777 dist
    cp ../../deploy-repo/iom-ui/* ./dist/ -rf
    ls -lrt ./dist/
    ls -ltr
    cf push -f ${ENVIRONMENT}.manifest.yml
    echo "deploy completed  for iom ui"
    # Deployment for approval ui
    echo "deploy started  for iom approval ui"
    cd ../iom-approval-ui
    ls -ltr
    mkdir -p dist  && chmod 777 dist
    cp ../../deploy-repo/iom-approval-ui/* ./dist/ -rf
    ls -lrt ./dist/
    cf push -f ${ENVIRONMENT}.manifest.yml
    echo "deploy completed  for iom approval ui"
    echo "deployment of for the service will be done and the ui will be excluded"
}



deployservices() {
    cd ../code-repo
    echo "deploy started  for iom-ui-service"
    MANIFESTFILE="./iom-ui-services/${ENVIRONMENT}.manifest.yml"
    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
    ROUTE_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
    JARPATH="../deploy-repo/iom-ui-services.jar"
    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${ROUTE_NAME} ${JARPATH} ${CF_DOMAIN}
    echo "deploy completed for iom-ui-service"
#
#    echo "deploy started  for iom-xfer-service"
#    MANIFESTFILE="./iom-xfer-services/${ENVIRONMENT}.manifest.yml"
#    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
#    ROUTE_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
#    if [[ -z ${ROUTE_NAME} ]]; then
#        echo "No Active Route Specified"
#        ROUTE_NAME="NA"
#    fi
#    CFAPPS=$(cf apps)
#    echo "cf apps results:\n${CFAPPS}"
#    echo "ROUTE_NAME: ${ROUTE_NAME}"
#    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${ROUTE_NAME} '$0 ~ routename {print $1}')
#    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
#    if [[ -z ${APP_NAME_ACTIVE} ]]; then
#        echo " No Active App"
#        APP_NAME_ACTIVE="NA"
#    fi
#    JARPATH="../deploy-repo/iom-ui-services.jar"
#    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
#    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${ROUTE_NAME} ${APP_NAME_ACTIVE} ${JARPATH} ${CF_DOMAIN}
#    echo "deploy completed for iom-xfer-service"
#
#    echo "deploy started  for iom-scheduler"
#    MANIFESTFILE="./iom-scheduler/${ENVIRONMENT}.manifest.yml"
#    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
#    ROUTE_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
#    if [[ -z ${ROUTE_NAME} ]]; then
#        echo "No Active Route Specified"
#        ROUTE_NAME="NA"
#    fi
#    CFAPPS=$(cf apps)
#    echo "cf apps results:\n${CFAPPS}"
#    echo "ROUTE_NAME: ${ROUTE_NAME}"
#    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${ROUTE_NAME} '$0 ~ routename {print $1}')
#    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
#    if [[ -z ${APP_NAME_ACTIVE} ]]; then
#        echo " No Active App"
#        APP_NAME_ACTIVE="NA"
#    fi
#    JARPATH="../deploy-repo/iom-scheduler.jar"
#    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
#    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${ROUTE_NAME} ${APP_NAME_ACTIVE} ${JARPATH} ${CF_DOMAIN}
#    echo "deploy completed for iom-scheduler"
#
#    echo "deploy started  for iom-approval-service"
#    MANIFESTFILE="./iom-approval-service/${ENVIRONMENT}.manifest.yml"
#    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
#    ROUTE_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
#    if [[ -z ${ROUTE_NAME} ]]; then
#        echo "No Active Route Specified"
#        ROUTE_NAME="NA"
#    fi
#    CFAPPS=$(cf apps)
#    echo "cf apps results:\n${CFAPPS}"
#    echo "ROUTE_NAME: ${ROUTE_NAME}"
#    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${ROUTE_NAME} '$0 ~ routename {print $1}')
#    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
#    if [[ -z ${APP_NAME_ACTIVE} ]]; then
#        echo " No Active App"
#        APP_NAME_ACTIVE="NA"
#    fi
#    JARPATH="../deploy-repo/iom-approval-service.jar"
#    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
#    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${ROUTE_NAME} ${APP_NAME_ACTIVE} ${JARPATH} ${CF_DOMAIN}
#    echo "deploy completed for iom-approval-service"
#
#    echo "Start list all the application in current space"
#    cf apps
#    echo "Complited list all the application in current space"
#
#    echo "Start iom-ui-service environment"
#    cf env iom-ui-service
#    echo "End iom-ui-service environment"
#
#    echo "Start iom-scheduler environment"
#    cf env iom-scheduler
#    echo "End iom-scheduler environment"
#
#    echo "Start iom-xfer-service environment"
#    cf env iom-xfer-service
#    echo "End iom-xfer-service environment"
#
#    echo "Start iom-approval-service environment"
#    cf env iom-approval-service
#    echo "End iom-xfer-service environment"

}

installcfcli
logintoconcourse

if [ -z "${DEPLOY_TYPE}" ]
then
  echo "services being deployed as DEPLOY_TYPE value not set"
  deployservices
elif [ "${DEPLOY_TYPE}" == "SERVICES" ]
then
  echo "services being deployed"
  deployservices
elif [ "${DEPLOY_TYPE}" == "UI" ]
then
  echo "ui being deployed"
  deployui
else
  echo "nothing being deployed DEPLOY TYPE value has incorrect value :" ${DEPLOY_TYPE}
fi

echo "********************************************************* ${ENVIRONMENT} deployments done"

