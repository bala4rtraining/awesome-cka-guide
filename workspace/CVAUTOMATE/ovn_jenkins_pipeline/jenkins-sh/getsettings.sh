#!/bin/bash

uxpass=$2
baseurl='https://stash.trusted.visa.com:7990'
exclude_repo='(ovn_personal|3rd-party-src|proof_of_concept|jenkins_backup|zzz_*)'
DATE=`date +%Y%m%d`
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREY='\033[0;37m'
BLUE='\e[34m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

function getsetting() {
  reponame=$1
  curl -s -o response.json -X GET -u "$uxpass" $baseurl/rest/api/latest/projects/OP/repos/$reponame/settings/pull-requests
  unapproveonupdatesetting=$(jq .unapproveOnUpdate response.json)
  requiredapproverssetting=$(jq .requiredApprovers response.json)
  if [ "$unapproveonupdatesetting" != "true" ]; then
       (>&2 echo -e ${RED}"[unapproveOnUpdate]: $reponame:" $unapproveonupdatesetting${NC})
  fi
  if (( $requiredapproverssetting < 2 )); then
       (>&2 echo -e ${RED}"[requiredApprovers]: $reponame:" $requiredapproverssetting${NC})
  fi
  echo "[unapproveOnUpdate]: $reponame:" $unapproveonupdatesetting >> getsettings.$DATE
  echo "[requiredApprovers]: $reponame:" $requiredapproverssetting >> getsettings.$DATE
}

while read -r REPONAME
do
   REPONAME="${REPONAME%\"}"
   REPONAME="${REPONAME#\"}"
   if [[ $REPONAME =~ $exclude_repo ]];
     then
       echo -e ${BLUE}"Ignoring repo: $REPONAME"${NC}
     else
       getsetting $REPONAME
   fi
done  < "${1:-/dev/stdin}"

exit