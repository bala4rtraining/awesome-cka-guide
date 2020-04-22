#!/usr/bin/env bash

# File: get_sonarqube_status.sh
# Purpose:
#     Uses the SonarQube API to retrieve latest code coverage metrics such as coverage percentage,
#     identified bugs, and alert status. It outputs the data into a JSON file which is then 
#     uploaded to sl73ovnapd112 and displayed as a table on https://ovndev.visa.com/OVNsonardata.html
# Jenkinsfile:
#     This script is executed weekly by https://jenkins-oce-corp.visa.com:8443/netproc/job/OVN/job/OVN_dev/job/Administration%20Jobs/job/sonarqube_weekly_report/
# To run script:
#     ./get_sonarqube_status.sh {filepath to ssh keyfile} {ssh username}
# Arguments:
#     ssh_key_filepath: filepath to the ssh keyfile
#     ssh_username: username of account in remote server 
#
# Script maintainer: NA - OVN Tools & Automation <NAOVNToolsAutomation@visa.com>
#

SSH_KEY_FILE=$1
SSH_USERNAME=$2
DATE=`date +%Y%m%d`
DATESTAMP=`date +%Y%m%d-%H:%M:%S%Z`
RED='\033[0;31m'
GRE='\033[0;32m'
BLU='\033[0;36m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
JSON_RESULT='sqube.projects_index.json'
JSON_OUTPUT_FILE=getsonarqubestatus.$DATE.json
URL='https://sonarqube.trusted.visa.com/api/projects/index'
#generated for svcovn-sonar
SONARQUBE_TOKEN='aa2bee2745785c0858baf786c53e979a32b4b57b'
COVERAGE=""
HTTPRC=$(curl -s -w '%{http_code}' -o $JSON_RESULT -u $SONARQUBE_TOKEN: $URL)
if [[ $HTTPRC -eq 200 ]] ; then
    PROJECT_LIST=$(jq -r '.[]|select(.k |contains("OP"))| .k' ${JSON_RESULT})
else
    echo "${RED}ERROR${NC}: Unable to get project list. HTTPRC=${HTTPRC}"
    exit 1
fi
PROJECT_COUNT=$(echo "$PROJECT_LIST" | wc -l)

function generate_json_file() {
    echo "Now processing $PROJECT_COUNT OVN registered projects from SonarQube"
    while read -r PROJECTKEY
    do
        getsonarqubestatus $PROJECTKEY
        echo $COVERAGE
    done  <<< "$PROJECT_LIST"

    echo '{"dateStamp": "'${DATESTAMP}'", "coverageInfo": [' ${COVERAGE:1} '] }' > $JSON_OUTPUT_FILE
    echo "Complete coverage list is stored in $JSON_OUTPUT_FILE"
}

function getsonarqubestatus() {
    local projectkey=$1

    URL='https://sonarqube.trusted.visa.com/api/issues/search?componentKeys='${projectkey}'&statuses=OPEN,CONFIRMED'
    JSON_RESULT='sqube.issues.json'
    HTTPRC=$(curl -s -w '%{http_code}' -o $JSON_RESULT -u $SONARQUBE_TOKEN: $URL)
    if [[ $HTTPRC -eq 200 ]] ; then
        myassigneeinfo=$(jq -rc '[ del(.issues[] | select(.assignee == null)) | .issues[].assignee] | unique' ${JSON_RESULT})
    else
        echo "${YELLOW}WARNING${NC}: Unable to get issues list for ${projectkey}. HTTPRC=${HTTPRC}"
        myassigneeinfo="[]"
    fi

    URL='https://sonarqube.trusted.visa.com/api/measures/component?metricKeys=coverage,bugs,alert_status,code_smells&component='${projectkey}
    JSON_RESULT='sqube.measures_component.json'
    HTTPRC=$(curl -w '%{http_code}' -s -o $JSON_RESULT -u $SONARQUBE_TOKEN: $URL)
    if [[ $HTTPRC -eq 200 ]] ; then
        mycoveragestring=$(jq -c '.component.measures[]|select(.metric=="coverage")|.value' ${JSON_RESULT})
        if [[ $mycoveragestring != "" ]]; then
            mybugsstring=$(jq -c '.component.measures[]|select(.metric=="bugs")|.value' ${JSON_RESULT})
            if [[ $mybugsstring != "" ]]; then
                myalertstatus=$(jq -c '.component.measures[]|select(.metric=="alert_status")|.value' ${JSON_RESULT})
                if [[ $myalertstatus != "" ]]; then
                    mycodesmells=$(jq -c '.component.measures[]|select(.metric=="code_smells")|.value' ${JSON_RESULT})
                    if [[ $mycodesmells != "" ]]; then
                        # Data is good, then put it all back together into a json block
                        mycoverageinfo=$(jq -c '.component|{"projectKey": .key} + {"codeCoverage": '${mycoveragestring}', "bugsFound": '${mybugsstring}', "alertStatus": '${myalertstatus}', "codeSmells": '${mycodesmells}', "assignees": '${myassigneeinfo}' }' ${JSON_RESULT} )
                        COVERAGE="$COVERAGE, $mycoverageinfo"
                    else
                      echo "${RED}WARNING${NC}: No code smell data available for project: $projectkey - please investigate "
                    fi
                else
                   echo "${RED}WARNING${NC}: No alert status available for project: $projectkey - please investigate "
                fi
            else
               echo "${RED}WARNING${NC}: No bugs count available for project: $projectkey - please investigate "
            fi
        else
           echo "${RED}WARNING${NC}: No coverage number available for project: $projectkey - please investigate "
        fi
    else
       echo "${YEL}WARNING${NC}: Unable to get coverage info for project: $projectkey. HTTPRC=${HTTPRC}"
       exit 1
    fi
}

function upload_json_file() {
    # only works if there is an ssh key to write to this directory
    echo "Now uploading sonarqube-status.json to sl73ovnapd112  (ovndev.visa.com)"
    scp -i "$SSH_KEY_FILE" -q "$JSON_OUTPUT_FILE" $SSH_USERNAME@sl73ovnapd112:/opt/app/data/nginx/html/sonarqube-status.json
    exit
}

function main() {
    generate_json_file
    upload_json_file
}

main