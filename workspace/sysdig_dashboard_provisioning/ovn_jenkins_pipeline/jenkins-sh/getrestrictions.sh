#!/bin/bash
upass=$2
baseurl='https://stash.trusted.visa.com:7990'
exclude_repo='(ovn_personal|3rd-party-src|proof_of_concept|jenkins_backup|zzz_*)'
expectedresult="refs/heads/master fast-forward-only refs/heads/master no-deletes refs/heads/master pull-request-only "
DATE=`date +%Y%m%d`
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREY='\033[0;37m'
NC='\033[0m'
BLUE='\e[34m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo "#Bitbucket settings retrieved by getrestrictions.sh on $DATE" > "getrestrictions.$DATE"

function getrestrict () {
  reponame=$1
  curl -s -o response.json -X GET -u "$upass" $baseurl/rest/branch-permissions/latest/projects/OP/repos/$reponame/restrictions
  restr=$(jq '.values[] |.matcher.id,.type' response.json | xargs -n2 | grep master | tr '\n' ' ')


  if [ "$restr" != "$expectedresult" ]; then
     (>&2 echo -e ${RED}"$reponame:" $restr${NC})
  fi
  echo "$reponame: $restr"  >> "getrestrictions.$DATE"
}

# Use a filename as $1
while read -r REPONAME
  do
   REPONAME="${REPONAME%\"}"
   REPONAME="${REPONAME#\"}"
   if [[ $REPONAME =~ $exclude_repo ]];
     then
       echo -e ${BLUE}"Ignoring repo: $REPONAME"${NC}
     else
       getrestrict $REPONAME
   fi
  done  < "${1:-/dev/stdin}"

exit