#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

if [[ -z "${LOCKSMITH_URL}" ]]; then
  echo "LOCKSMITH_URL is not set, defaulting to http://locksmith-api.apps-zb.homedepot.com/api/grants"
  LOCKSMITH_URL="http://locksmith-api.apps-zb.homedepot.com/api/grants"
fi
 CHG_NUMBER=`CHG0300505`
  # get CHG # from environment (e.g. $CHG_NUMBER)
  echo "invoking LockSmith for $CHG_NUMBER"

  set -x
  RESPONSE=$(curl -i -X POST \
    -H "accept: application/json" \
    -H "content-type: application/json" \
    -d "{ \"service_now_record\": \"$CHG_NUMBER\"}" \
    "$LOCKSMITH_URL")
  set +x

  STATUS=$(echo $RESPONSE | grep HTTP |  awk '{print $2}')

  if [ "$STATUS" -eq "200" ] || [ "$STATUS" -eq "201" ]; then
      echo "success: ${RESPONSE}";
      exit;
  else
      echo "failed locksmith validation: ${RESPONSE}";
      exit 1;
  fi