#!/bin/bash
# File:      validateINI.sh
# Purpose:   1. validate ansible INI files
# Requirements:
#            1. ansible-inventory command
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

function test_INI {
   local inventory_name=$1
   out=$(ansible-inventory --graph -i $inventory_name 2>&1 | grep '\[WARNING\]' | wc -l)
   if [ $out -eq 0 ]; then
    let goodcount+=1
   else
    let badcount+=1
    failed_files+=${inventory_name#$PWD/}
    failed_files+=', '
    parse_error+=$(ansible-inventory --graph -i $inventory_name 2>&1 | grep -v '|' | grep -v '@')
    parse_error+='\n'
   fi
}


list_ansible_inventory_name=$(find $scanrootdir/inventories -type f -name \hosts | sort | uniq)
countfiles=$(find $scanrootdir/inventories -type f -name \hosts | sort | uniq| wc -l)

for inventory_name in $list_ansible_inventory_name; do
   test_INI $inventory_name
done
failed_files+=' ]'
echo "INFO- Number of INI files to validate: $countfiles"
printf "INFO- Completed Directory %s: Good count=%d Bad count=%d\n" $scanrootdir $goodcount $badcount
if [ $badcount -ne 0 ]; then
echo -e "ERROR- validation check failed files: $failed_files"
echo -e "ERROR- parsing errors: $parse_error"
fi
exit $badcount
