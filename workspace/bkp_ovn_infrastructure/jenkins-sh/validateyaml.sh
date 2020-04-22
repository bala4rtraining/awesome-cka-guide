#!/bin/bash
# File:      validateyaml.sh
# Purpose:   1. validate all the yaml in the repository
# Requirements:
#            1. ruby
#

scanrootdir=$1
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

goodcount=0
badcount=0
failed_files='[ '
parse_error=''

function test_yaml {
   local filename=$1
   out=$(ruby -e "require 'yaml';puts YAML.load_file('$filename')"  2>&1 /dev/null)
   if [ $? -eq 0 ]; then
    let goodcount+=1
   else
    let badcount+=1
    failed_files+=${filename#$PWD/}
    failed_files+=', '
    parse_error+=$(ruby -e "require 'yaml';puts YAML.load_file('$filename')"  2>&1 /dev/null)
    parse_error+='\n'
   fi
}


listfile=$(find $scanrootdir -type f -name \*.yml | sort | uniq)
countfiles=$(find $scanrootdir -type f -name \*.yml | sort | uniq| wc -l)

for filename in $listfile; do
   test_yaml $filename
done
failed_files+=' ]'

echo "INFO- Number of YAML files to validate: $countfiles"
printf "INFO- Completed Directory %s: Good count=%d Bad count=%d\n" $scanrootdir $goodcount $badcount
if [ $badcount -ne 0 ]; then
echo -e "ERROR- validation check failed files: $failed_files"
echo -e "ERROR- parsing errors: $parse_error"
fi
exit $badcount
