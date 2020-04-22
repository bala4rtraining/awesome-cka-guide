#!/bin/bash
# This program is used to identify the servers from the DEV inventory list that may be available (not yet assigned).
# This assumes that we have allocated all the used servers in the usual host files in this repostiory.
#

# Set current directory to the base of this shellscript
cd "$(dirname "$0")"
outputfile="/tmp/devlist.txt"
outputfile2='/tmp/devlistsql.csv'
echo "#File created by devlist.sh" > $outputfile
echo inventoryfilename,hostname,ipaddress > $outputfile2

function checkhosts() {
    local hostprefix=$1
    local outfile=$2
    local previous=13
    local tempfile='/tmp/tmp.devlist-files.txt'

    sh -c "cd ..;grep -h ^\\\[${hostprefix} inventories/*/dc*/hosts */inventories/*/dc*/hosts inventories/*/hosts 2>/dev/null| grep -v vars| awk '/sl73ovnap[dq][0-9][0-9]]/{print \$0}' |sort | uniq > $tempfile"
    sh -c "cd ..;grep -h ^\\\[${hostprefix} inventories/*/dc*/hosts */inventories/*/dc*/hosts inventories/*/hosts 2>/dev/null| grep -v vars| awk '/sl73ovnap[dq][0-9][0-9][0-9]]/{print \$0}' |sort | uniq >> $tempfile"

    while IFS='' read -r line || [[ -n "$line" ]]; do

        if [[ ${line:14:1} == ']' ]] ; then   # Calculate gaps for three digit numbers
            if ((${line:11:1}=='0')) ; then   # three digit numbers beginning with 0
                n=${line:12:2}
            else                              # three digit numbers not beginning with 0
                n=${line:11:3}
            fi
            if (( n != previous + 1 )) ; then
                if (( previous + 1 == n - 1 )) ; then
                   printf "Not reserved/Available: %s%3.3d\n" ${hostprefix} $(( previous + 1 ))
                else
                   printf "Not reserved/Available: %s%3.3d-%3.3d\n" ${hostprefix} $(( previous + 1 )) $(( n - 1 ))
                fi
            fi
            previous=$n
        fi

        #inventory list creation(csv file) for uploading to the database

        hostname=${line:1:${#line}-2}
        inventories=$(sh -c "cd ..;fgrep -r $line inventories */inventories 2>/dev/null")
        inventoriesfile=${inventories%%:*}

        if [[ $inventoriesfile == *"decom"* || $inventoriesfile == *"automation"* || $inventoriesfile == *":"* ]] ; then
            ipaddress=""
        else
            ipaddress=$(nslookup  $hostname | grep 'Address'| tail -1 | awk '{print $2}')

        fi

        if [[ $ipaddress == *"#"* ]] ; then
            ipaddress=""
            echo "The IP Address (for $hostname) could not be resolved using nslookup, is it decomissioned??"

        fi
        echo "$inventoriesfile,$hostname,$ipaddress" >> $outputfile2


        #Text file creation for developer use

        sh -c "cd ..;fgrep -r $line inventories */inventories 2>/dev/null | grep -v ':#' >> $outfile"
        X=$(sh -c "cd ..;fgrep -r ${line} inventories */inventories 2>/dev/null| grep -v ':#'| wc -l")
        if (( $X > 1 )) ; then
           echo duplicate: $(sh -c "cd ..;fgrep -r ${line} inventories */inventories 2>/dev/null"| grep -v ':#')
        fi
    done < "$tempfile"
}

checkhosts 'sl73ovnapd' $outputfile
checkhosts 'sl73ovnapq' $outputfile
echo "Created summary file: $outputfile"
echo "Created sql summary file: $outputfile2"

