#!/bin/bash

source "${BASH_SOURCE%/*}/flow-env.sh"

set -e -x

./gradlew assemble
flow sonar scan $ENVIRONMENT


################Sonar Build Breaker code###############################################################################################

WORKSPACE="../code-repo/"
echo "######### Sonar output is captured in sonar.log #################################################################################"
unset content
unset stat
unset analysis_id
unset output
unset blockers
unset critial
sleep 15
cat ${WORKSPACE}/.sonar/report-task.txt
URL=`sed -n '5p' ${WORKSPACE}/.sonar/report-task.txt| sed 's/ceTaskUrl=//'`
analysis_URL=https://sonar.homedepot.com/api/qualitygates/project_status?analysisId=
content=`curl -k -s $URL`
echo $content >> ${WORKSPACE}/curl_initial.log

# Checking the analysis/process status to be posted
stat=`echo $content | sed -e 's/^.*"status":"\([^"]*\)".*$/\1/'`

echo "processing status:"$stat
echo
echo
if [ $stat = "FAILED" ]; then
        echo
       echo "################################## Build Failed, check the Sonar-qa DashBoard #############################################"
                exit 1
 else
         while [ $stat != "SUCCESS" ]
                do

               #content=`curl -k -s $URL -sslv1`
                content=`curl -k -s $URL`
                echo $content >> ${WORKSPACE}/curl_loop.log
               stat=`echo $content | sed -e 's/^.*"status":"\([^"]*\)".*$/\1/'`
        echo
        echo
        echo "########################"
            echo "processing status:"$stat
        echo "########################"

                if [ $stat == "FAILED" ]; then
        echo
        echo "################################## Build Failed, check the Sonar-qa DashBoard #############################################"
                  exit 1
            else
                  sleep 30
                fi

        done
fi
Analysis_Stat=`curl -k -s $URL`
analysis_id=`echo $Analysis_Stat | sed -e 's/^.*"analysisId":"\([^"]*\)".*$/\1/'`
echo
echo "ANALYSIS ID:"$analysis_id
quality_gate=`curl -k -s $analysis_URL$analysis_id`
echo $quality_gate >> ${WORKSPACE}/curl_quality_gate.log
output=`echo $quality_gate | sed -e 's/^.*"projectStatus":{"status":"\([^"]*\)".*$/\1/'`

echo "########################"
echo "Quality gate:"$output
echo "########################"

######################################################
blockers=`echo $quality_gate | awk -F'[:",]+' '{print $17}'`
critical=`echo $quality_gate | awk -F'[:",]+' '{print $29}'`

if [[ $output = "ERROR" ]]; then
  echo
  echo "################################## Build Failed due to below reason #############################################\n"
            echo "              1. Blocker_violations  =  "$blockers
            echo "              2. Critical_violations =  "$critical
            echo
            echo
        exit 1
else
           echo "################################## Build passed the Quality gate #############################################"

fi
