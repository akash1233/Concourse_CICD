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



# BG Setup for services
bg_deploy() {
MANIFESTFILE=$1
APP_NAME=$2
HOSTNAME=$3
JARPATH=$4
CF_DOMAIN=$5
APP_NAME_ACTIVE=$6

#Define the app types
BLUE=${APP_NAME}
GREEN="${BLUE}-B"
TIMESTAPEDAPPNAME=${APP_NAME}_$(date +%Y-%m-%d-%H-%M)


#Rename the active app with a timestamp , stop it and unmap the route
if [[ "${APP_NAME_ACTIVE}" == "NA" ]]; then
    echo "No active app so going ahead with deployments"
    else
    echo "Renaming the app and timestamping it "
    cf rename ${APP_NAME_ACTIVE} ${TIMESTAPEDAPPNAME}
    cf unmap-route ${TIMESTAPEDAPPNAME} apps-${CF_DOMAIN} -n ${HOSTNAME}
    if [[ "${ENVIRONMENT}" == "prod"* ]]; then
    cf unmap-route ${TIMESTAPEDAPPNAME} apps.homedepot.com -n ${HOSTNAME}
    fi
    cf stop ${TIMESTAPEDAPPNAME}
fi

#Specify the full route name
ROUTE_NAME=${HOSTNAME}.apps-${CF_DOMAIN}


# create the GREEN application for ui and services application
if [[ "${JARPATH}" == "NA" ]]; then
   cf push $GREEN -f ${MANIFESTFILE} | tee pushoutput.txt
   else
   cf push $GREEN -f ${MANIFESTFILE} -p ${JARPATH} | tee pushoutput.txt
fi




# ensure it starts by grepping the text 'requested state: started'
if grep -Fxq "requested state: started" pushoutput.txt; then
echo "requested text found- Deploy completed"
else
echo "Error Deploying!! requested state: started not found"
exit 125
fi


# App renaming
cf rename $GREEN $BLUE
echo "Blue Green Deploy's for ${APP_NAME} Completed"
}


deployui() {
    # Deployment for iom ui
    echo "deploy started  for iom ui"
    cd ../code-repo/iom-ui
    if [[ "${UI_TYPE}" == "UI" ]]; then
        ls -ltr
        mkdir -p dist  && chmod 777 dist
        cp ../../deploy-repo/iom-ui/* ./dist/ -rf
        ls -lrt ./dist/
        MANIFESTFILE="${ENVIRONMENT}.manifest.yml"
        APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
        HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
        JARPATH=NA
        CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
        CFAPPS=$(cf apps)
        echo "cf apps results:\n${CFAPPS}"
        echo "ROUTE_NAME: ${ROUTE_NAME}"
        APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
        echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
        if [[ -z ${APP_NAME_ACTIVE} ]]; then
            echo " No Active App"
            APP_NAME_ACTIVE="NA"
        fi
        bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
        echo "deploy completed  for iom ui"


        echo "----------------------------------------------------------------------------------------------------------------"
        echo "----------------------------------------------------------------------------------------------------------------"
    else
        # Deployment for approval ui
        echo "deploy started  for iom approval ui"
        cd ../iom-approval-ui
        ls -ltr
        mkdir -p dist  && chmod 777 dist
        cp ../../deploy-repo/iom-approval-ui/* ./dist/ -rf
        ls -lrt ./dist/
        MANIFESTFILE="${ENVIRONMENT}.manifest.yml"
        APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
        HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
        JARPATH=NA
        CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
        CFAPPS=$(cf apps)
        echo "cf apps results:\n${CFAPPS}"
        echo "ROUTE_NAME: ${ROUTE_NAME}"
        APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
        echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
        if [[ -z ${APP_NAME_ACTIVE} ]]; then
            echo " No Active App"
            APP_NAME_ACTIVE="NA"
        fi
        bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
        echo "deploy completed  for iom approval ui"
        echo "deployment of for the service will be done and the ui will be excluded"

        echo "----------------------------------------------------------------------------------------------------------------"
        echo "----------------------------------------------------------------------------------------------------------------"
     fi
}



deployservices() {

    cd ../code-repo
    echo "deploy started  for iom-ui-service"
    MANIFESTFILE="./iom-ui-services/${ENVIRONMENT}.manifest.yml"
    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
    HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
    JARPATH="../deploy-repo/iom-ui-services.jar"
    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
    CFAPPS=$(cf apps)
    echo "cf apps results:\n${CFAPPS}"
    echo "ROUTE_NAME: ${ROUTE_NAME}"
    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
    if [[ -z ${APP_NAME_ACTIVE} ]]; then
        echo " No Active App"
        APP_NAME_ACTIVE="NA"
    fi
    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
    echo "deploy completed for iom-ui-service"

    echo "----------------------------------------------------------------------------------------------------------------"
    echo "----------------------------------------------------------------------------------------------------------------"

    echo "deploy started  for iom-xfer-service"
    MANIFESTFILE="./iom-xfer-services/${ENVIRONMENT}.manifest.yml"
    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
    HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
    JARPATH="../deploy-repo/iom-xfer-services.jar"
    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
    CFAPPS=$(cf apps)
    echo "cf apps results:\n${CFAPPS}"
    echo "ROUTE_NAME: ${ROUTE_NAME}"
    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
    if [[ -z ${APP_NAME_ACTIVE} ]]; then
        echo " No Active App"
        APP_NAME_ACTIVE="NA"
    fi
    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
    echo "deploy completed for iom-xfer-service"

    echo "----------------------------------------------------------------------------------------------------------------"
    echo "----------------------------------------------------------------------------------------------------------------"



    echo "deploy started  for iom-scheduler"
    MANIFESTFILE="./iom-scheduler/${ENVIRONMENT}.manifest.yml"
    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
    HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
    JARPATH="../deploy-repo/iom-scheduler.jar"
    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
    CFAPPS=$(cf apps)
    echo "cf apps results:\n${CFAPPS}"
    echo "ROUTE_NAME: ${ROUTE_NAME}"
    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
    if [[ -z ${APP_NAME_ACTIVE} ]]; then
        echo " No Active App"
        APP_NAME_ACTIVE="NA"
    fi
    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
    echo "deploy completed for iom-scheduler"


    echo "----------------------------------------------------------------------------------------------------------------"
    echo "----------------------------------------------------------------------------------------------------------------"



    echo "deploy started  for iom-approval-service"
    MANIFESTFILE="./iom-approval-service/${ENVIRONMENT}.manifest.yml"
    APP_NAME=$(awk '/name:/ {print $NF}' "${MANIFESTFILE=}")
    HOST_NAME=$(awk '/host:/ {print $NF}' "${MANIFESTFILE=}")
    JARPATH="../deploy-repo/iom-approval-service.jar"
    CF_DOMAIN="$(echo $CF_API | cut -d '-' -f 2)"
    CFAPPS=$(cf apps)
    echo "cf apps results:\n${CFAPPS}"
    echo "ROUTE_NAME: ${ROUTE_NAME}"
    APP_NAME_ACTIVE=$(cf apps | awk -v routename=${HOST_NAME} '$0 ~ routename {print $1}')
    echo "APP_NAME_ACTIVE: ${APP_NAME_ACTIVE}"
    if [[ -z ${APP_NAME_ACTIVE} ]]; then
        echo " No Active App"
        APP_NAME_ACTIVE="NA"
    fi
    bg_deploy ${MANIFESTFILE} ${APP_NAME} ${HOST_NAME} ${JARPATH} ${CF_DOMAIN} ${APP_NAME_ACTIVE}
    echo "deploy completed for iom-approval-service"

    echo "----------------------------------------------------------------------------------------------------------------"
    echo "----------------------------------------------------------------------------------------------------------------"


    echo "Start list all the application in current space"
    cf apps
    echo "Complited list all the application in current space"

    echo "Start iom-ui-service environment"
    cf env iom-ui-service
    echo "End iom-ui-service environment"

    echo "Start iom-scheduler environment"
    cf env iom-scheduler
    echo "End iom-scheduler environment"

    echo "Start iom-xfer-service environment"
    cf env iom-xfer-service
    echo "End iom-xfer-service environment"

    echo "Start iom-approval-service environment"
    cf env iom-approval-service
    echo "End iom-xfer-service environment"

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