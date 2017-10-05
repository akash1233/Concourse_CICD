#!/bin/bash
source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x
echo "Deployment repo content"
ls -lrt ../deploy-repo

installcfcli() {
    echo "installing cf cli"
    wget -qO- 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' | tar -zxf - -C /usr/local/bin
    echo "deploying apps to ZONE ${ENVIRONMENT}"
}

logintoconcourse() {
    cf login -a ${CF_API} -u ${DEPLOYMENT_USER} -p ${DEPLOYMENT_PWD} -o ${CF_ORG} -s ${CF_SPACE}
}


deployui() {
    # Deployment for iom ui
    echo "deploy started  for iom ui"
    cd ../code-repo/iom-ui
    ls -ltr
    ls ../../deploy-repo/
    ls ../../
    cp ../../deploy-repo/iom-ui/* ./dist/ -rf
    ls -lrt ./dist/
    cf push -f ${ENVIRONMENT}.manifest.yml
    cf push -f ${ENVIRONMENT}.manifest.yml
    echo "deploy completed  for iom ui"

    # Deployment for approval ui
    echo "deploy started  for iom approval ui"
    cd ../iom-approval-ui
    ls -ltr
    cp ../../deploy-repo/iom-approval-ui/* ./dist/ -rf
    ls -lrt ./dist/
    cf push -f ${ENVIRONMENT}.manifest.yml
    echo "deploy completed  for iom approval ui"
    echo "deployment of for the service will be done and the ui will be excluded"
    cd ../code-repo/
    ls -lrt
}



deployservices() {
    cd ../code-repo
    echo "deploy started  for iom-ui-service"
    cf push -f ./iom-ui-services/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-ui-services.jar
    echo "deploy completed for iom-ui-service"

    echo "deploy started  for iom-xfer-service"
    cf push -f ./iom-xfer-services/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-xfer-services.jar
    echo "deploy completed for iom-xfer-service"

    echo "deploy started  for iom-scheduler"
    cf push -f ./iom-scheduler/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-scheduler.jar
    echo "deploy completed for iom-scheduler"

    echo "deploy started  for iom-approval-service"
    cf push -f ./iom-approval-service/${ENVIRONMENT}.manifest.yml -p ../deploy-repo/iom-approval-service.jar
    echo "deploy completed for iom-approval-service"


    echo "Start list all the application in current space"
    cf apps
    echo "Complited list all the application in current space"

    echo "Start list all the application in current space"
    cf apps
    echo "Complited list all the application in current space"

    echo "Start iom-ui environment"
    cf env iom-ui
    echo "End iom-ui environment"

    echo "Start iom-approval-ui environment"
    cf env iom-approval-ui
    echo "End iom-approval-ui environment"

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



