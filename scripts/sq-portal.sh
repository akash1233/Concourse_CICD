#!/bin/sh

curl -o sq-publisher.jar -X GET https://maven.artifactory.homedepot.com/artifactory/libs-release-local/com/homedepot/quality/publisher/1.0.1/publisher-1.0.1.jar


verify_presence_of_required_params () {
  if [ -z "$PIPELINE_ID" ] ; then
    echo "PIPELINE_ID must be set"
    exit 1
  fi

  if [ -z "$BUILD_ID" ] ; then
    echo "BUILD_ID must be set"
    exit 1
  fi

  if [ -z "$BUILD_NAME" ] ; then
    echo "BUILD_NAME must be set"
    exit 1
  fi

  if [ -z "$APPLICATION_NAME" ] ; then
    echo "APPLICATION_NAME must be set"
    exit 1
  fi

  if [ -z "$ENVIRONMENT" ] ; then
    echo "ENVIRONMENT must be set"
    exit 1
  fi

  if [ -z "$STAGE_NAME" ] ; then
    echo "STAGE_NAME must be set"
    exit 1
  fi

  if [ -z "$STAGE_STATUS" ] ; then
    echo "STAGE_STATUS must be set"
    exit 1
  else
    if [ "$STAGE_STATUS" != "STARTED" ] && [ "$STAGE_STATUS" != "COMPLETED" ] && [ "$STAGE_STATUS" != "FAILED" ]; then
      echo "STAGE_STATUS is $STAGE_STATUS and it must be STARTED, COMPLETED, or FINISHED"
      exit 1
    fi
  fi

  if [ -r $VERSION_FILE ] ; then
    VERSION=$(cat $VERSION_FILE)
  else
    echo "SVERSION_FILE must be set and must be a file with the version number"
    exit 1
  fi

}

verify_presence_of_required_params

PUBLISH_COMMAND="java -jar sq-publisher.jar post_message
  -pid ${PIPELINE_ID}
  -bid ${BUILD_ID}
  -bname ${BUILD_NAME}
  -appname ${APPLICATION_NAME}
  -env ${ENVIRONMENT}
  -stage ${STAGE_NAME}
  -s ${STAGE_STATUS}
  -v ${VERSION}
  "
# !----EVERYTHING AFTER THIS IS OPTIONAL-----!

if [ -n "$SQDEV" ] ; then
  echo "Publishing to dev SQ Portal"
  PUBLISH_COMMAND=$PUBLISH_COMMAND"-sqdev"
else
  echo "Publishing to prod SQ Portal"
  PUBLISH_COMMAND=$PUBLISH_COMMAND"-sqprod"
fi

if [ -n "$REPO_ID" ] ; then
  PUBLISH_COMMAND=$PUBLISH_COMMAND"-gitid ${REPO_ID}"
fi

if [ -n "$TEST_TYPE" ] ; then
  if [ "$TEST_TYPE" == "UNIT" ] || [ "$TEST_TYPE" == "FUNCTIONAL" ] || [ "$TEST_TYPE" == "SMOKE" ] || [ "$TEST_TYPE" == "REGRESSION" ]; then
    PUBLISH_COMMAND=$PUBLISH_COMMAND" -test_type "$TEST_TYPE
  else
    echo "TEST_TYPE is $TEST_TYPE and it must be UNIT, FUNCTIONAL, SMOKE, or REGRESSION"
    exit 1
  fi
fi

if [ -n "$TEST_REPORT_DIRS" ] ; then
  if [ -z "$TEST_TYPE" ] ; then
    echo "If TEST_REPORT_DIRS is defined you must specify TEST_TYPE"
    exit 1
  fi
  if [ -d "$TEST_REPORT_DIRS" ] ; then
    PUBLISH_COMMAND=$PUBLISH_COMMAND" -dirs "$TEST_REPORT_DIRS" -adtr"
  else
    echo "TEST_REPORT_DIRS is not a directory\nPlease set this to a directory containing your XUNIT/JUNIT files"
    exit 1
  fi
fi


${PUBLISH_COMMAND}
