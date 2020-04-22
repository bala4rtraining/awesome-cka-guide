#!/bin/bash
# File:      validatejenkinsfile.sh
# Purpose:   1. validate all the jenkinsfiles in the repository
scanrootdir=$1
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
  fi
JENKINS_URL='https://jenkins-oce-corp.visa.com:8443/netproc'
JENKINS_CRUMB=`curl -s -k --user svcnpovndev:114fc9cc657662eafe1ba5b0e5cf3f4457 "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"`
goodcount=0
badcount=0
skipped=0
failed_files='[ '
parse_error=''

function test_jenkinsfile {
  local filename=$1
  local fname=`echo $filename | cut -d'/'  -f7,8 `
  echo -e " Validating the file : $fname "
  
   out=`curl -s -k --user svcnpovndev:114fc9cc657662eafe1ba5b0e5cf3f4457 -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<$filename" $JENKINS_URL/pipeline-model-converter/validate > tmp.jenkinsfile`
  errValue=$( grep -ic "Errors encountered validating" tmp.jenkinsfile)
  tokenError=$( grep -ic " did not contain the" tmp.jenkinsfile)
  if [ $errValue -eq 0 -a  $tokenError -eq 0 ]; then
    let goodcount+=1
    echo -e " Sucessfully validated : $fname: [STATUS: OK] \n"

   else
    temp_parse_error=$(curl -s -k --user svcnpovndev:114fc9cc657662eafe1ba5b0e5cf3f4457 -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<$filename" $JENKINS_URL/pipeline-model-converter/validate)
    echo $temp_parse_error | grep "shared" > /dev/null
   if [ $? -ne 0 ]; then
    let badcount+=1
    failed_files+=${filename#$PWD/}
    failed_files+=','
    parse_error+="ERROR parsing  filename:$fname"
    parse_error+='\n'
    parse_error+='--------------------------------'
    parse_error+='\n'
    parse_error+=$temp_parse_error
    parse_error+='\n'
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "  Validation failed for : $fname: ${RED}[STATUS: FAIL]${NC} \n"
    else
    let skipped+=1
    echo -e " Skipped validation of the file : $fname: [STATUS: SHARED LIBRARY] \n"
   fi
   fi
   
}


listfile=$(find $scanrootdir -type f -name \*.jenkinsfile | sort | uniq)
countfiles=$(find $scanrootdir -type f -name \*.jenkinsfile | sort | uniq| wc -l)

for filename in $listfile; do
   let tot_file+=1
   test_jenkinsfile $filename
	
done
failed_files+=' ]'

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}INFO- Number of jenkinsfile files to validate: $countfiles ${NC}"
printf "${GREEN}INFO- Completed Directory %s: Good count=%d Bad count=%d skipped(shared lib files)=%d${NC} \n" $scanrootdir $goodcount $badcount $skipped

if [ $badcount -ne 0 ]; then
echo -e "\e[31mERROR- validation check failed files: $failed_files\e[0m\n"
echo -e "$parse_error"
exit 1;
fi
exit 0
