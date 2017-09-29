#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

echo "============================= NEW NEW"

if [[ -z "${ARTIFACT_BUILD_DIRECTORY}" ]]; then
  echo "ARTIFACT_BUILD_DIRECTORY not set, defaulting to ../dist"
  export ARTIFACT_BUILD_DIRECTORY=../dist
fi

ls -lrt ../dist
if [[ -z "${UI_ONLY_UPLOAD}" ]]; then
  mkdir -p upload-iom-approval-service
  mkdir -p upload-iom-scheduler
  mkdir -p upload-iom-ui-services
  mkdir -p upload-iom-xfer-services

  cp -f ../dist/iom-approval-service.jar upload-iom-approval-service/
  cp -f ../dist/iom-scheduler.jar upload-iom-scheduler/
  cp -f ../dist/iom-ui-services.jar upload-iom-ui-services/
  cp -f ../dist/iom-xfer-services.jar upload-iom-xfer-services/

  ls -lrt

  cd ../code-repo/

  export ARTIFACT_BUILD_DIRECTORY=./upload-iom-approval-service
  echo "${ARTIFACT_BUILD_DIRECTORY}============Uploading================= ${ENVIRONMENT}"
  flow artifactory upload $ENVIRONMENT

  export ARTIFACT_BUILD_DIRECTORY=./upload-iom-scheduler
  echo "${ARTIFACT_BUILD_DIRECTORY}============Uploading================= ${ENVIRONMENT}"
  flow artifactory upload $ENVIRONMENT

  export ARTIFACT_BUILD_DIRECTORY=./upload-iom-ui-services
  echo "${ARTIFACT_BUILD_DIRECTORY}============Uploading================= ${ENVIRONMENT}"
  flow artifactory upload $ENVIRONMENT

  export ARTIFACT_BUILD_DIRECTORY=./upload-iom-xfer-services
  echo "${ARTIFACT_BUILD_DIRECTORY}============Uploading================= ${ENVIRONMENT}"
  flow artifactory upload $ENVIRONMENT

else

  flow artifactory upload $ENVIRONMENT
fi