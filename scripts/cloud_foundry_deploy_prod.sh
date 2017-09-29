#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x


echo "Deployment repo content"
ls -lrt ../deploy-repo

echo "installing cf cli"

wget -qO- 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' | tar -zxf - -C /usr/local/bin

echo "deploying apps to ZONE ${ENVIRONMENT}"


cf login -a ${CF_API_ZONE_URL} -u ${DEPLOYMENT_USER} -p ${DEPLOYMENT_PWD} -o ${CF_ORG} -s ${CF_SPACE}

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

echo "deploy started  for iom ui"

cd ../code-repo/iom-ui

ls -ltr

echo "building the project"

npm install -s && npm install -g yarn

#TODO change this target

yarn run build:${BUILD_TARGET}

cf push -f ${ENVIRONMENT}.manifest.yml

echo "deploy completed  for iom ui"
cd ..

# Deployment for approval ui
echo "deploy started  for iom approval ui"

cd ./iom-approval-ui

ls -ltr

echo "building the project"

npm install -s && npm install -g yarn

#TODO change this target

yarn run build:${BUILD_TARGET}

cf push -f ${ENVIRONMENT}.manifest.yml

echo "deploy completed  for iom approval ui"


echo "deploy started  for iom-ui-service"
cf push -f ./iom-ui-services/${ENVIRONMENT}.manifest.yml -p ../../deploy-repo/iom-ui-services.jar
echo "deploy completed for iom-ui-service"

echo "deploy started  for iom-xfer-service"
cf push -f ./iom-xfer-services/${ENVIRONMENT}.manifest.yml -p ../../deploy-repo/iom-xfer-services.jar
echo "deploy completed for iom-xfer-service"

echo "deploy started  for iom-scheduler"
cf push -f ./iom-scheduler/${ENVIRONMENT}.manifest.yml -p ../../deploy-repo/iom-scheduler.jar
echo "deploy completed for iom-scheduler"

echo "deploy started  for iom-approval-service"
cf push -f ./iom-approval-service/${ENVIRONMENT}.manifest.yml -p ../../deploy-repo/iom-approval-service.jar
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

echo "********************************************************* ${ENVIRONMENT} done"
