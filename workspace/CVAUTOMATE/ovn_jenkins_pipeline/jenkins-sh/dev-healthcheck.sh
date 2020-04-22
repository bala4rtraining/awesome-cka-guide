#!/bin/bash
#
# File: check_health.sh
# Purpose: 1. Read from an input text file, e.g. devlist.txt and check the health of a list of servers. Current health check function include: 1. ssh is up and available on port 22. 2. file system is <80% full
#          2. Produce a tabular report stored in a .csv file named hoststatus-yyyy-mm-dd.csv
#
# Usage: ./dev-healthcheck.sh

#function to fill in the table html
function fill_html_table(){
    echo "<tr>
    <td>$1</td>" >> table.html
    day=0
    scan_day=0
    tac "/tmp/history.txt" | while IFS= read line; do
        if [[ $line = *"$1"* && $line = *"sshUnavailable"* ]]
        then
            echo "<td><font color=\"red\">N>>sshUnavailable</font></td>" >> table.html
            day=$((day + 1))
        elif [[ $line = *"$1"* && $line = *"filespaceWarning"* ]]
        then
            echo "<td><font color=\"red\">N>>filespaceWarning</font></td>" >> table.html
            day=$((day + 1))
        elif [[ $line = *"*"* ]]
        then
            scan_day=$((scan_day + 1))
            if [ $day -lt $scan_day ]
            then
                echo "<td><font color=\"green\">Y</font></td>" >> table.html
                day=$((day + 1))
            fi
        fi
        #scan 7 days
        if [ $scan_day -ge 7 ]
        then
            break
        fi
    done
    echo "</tr>" >> table.html
}

#update dev list
chmod 777 ovn_infrastructure/inventories/devlist.sh
chmod 400 ovn_infrastructure/config/id_dev
./ovn_infrastructure/inventories/devlist.sh

#useful constants for ANSI color and tput
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTGREY='\033[0;37m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)


#Prepare
DATE=`date +%Y-%m-%d`
outputfile="hoststatus-$DATE.csv"
outputfile_json="hoststatus-$DATE.json"
inputfile="/tmp/devlist.txt"

echo "*****************************************************************"
echo "${BOLD}start checking...${NORMAL}"
echo "*****************************************************************"
echo "host_name,ssh_return_code,file_storage_test,most_used_filesystem" > $outputfile

totalhost=0
fail_ssh_host=0
storage_exceed_host=0

#create a file if not exist
history_file="/tmp/history.txt"
touch $history_file
echo "***********************$DATE***********************" >> $history_file


#create html file
echo "<!DOCTYPE html>
<html>
<head>
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

tr:nth-child(even) {
    background-color: #dddddd;
}
</style>
</head>
<body>

<h2>$DATE - Status of Unhealthy Dev Servers in the Past 7 days</h2>

<table>
  <tr>
    <th>Server</th>
    <th>Day7(Today)</th>
    <th>Day6</th>
    <th>Day5</th>
    <th>Day4</th>
    <th>Day3</th>
    <th>Day2</th>
    <th>Day1</th>
  </tr>" >> table.html


while IFS='' read -r line || [[ -n "$line" ]]; do
	# -n prevent it from reading stdin, because read command reads from stdin

    #avoid reading:1.lines without server info,e.g. first line 2.lines containing decom or automation
    if [[ $line != *":"* || $line = *"decom"* || $line = *"automation"* ]]
    then
        continue;
    fi

    totalhost=$((totalhost + 1))

    bracket_host=${line//*:/} #e.g. [sl73ovnapq285]
    raw_host=${bracket_host:1:${#bracket_host}-2} #e.g. sl73ovnapq285

    ssh_return_code=0
    #-q:suppress welcome information #-o:avoid host verification
    #-oBatchMode: disable passphrase/password querying
    set -o pipefail
    dfinfo=$(ssh -q -n -o "StrictHostKeyChecking no" -o ConnectTimeout=10 -oBatchMode=yes -i ovn_infrastructure/config/id_dev root@"$raw_host" \
      "df" | sort -r -k 5 -i) ||  ssh_return_code=$? #Filesystem,Size,Used,Avail,Capacity,iused,ifree,%iused,Mounted on

    max_system=unknown
    max_storage=0

    #check %iused of different file systems
    if [ $ssh_return_code -eq 0 ]
    then
        #leave out the first line
        df_systemonly_info=$(tail -n +2 <<< "$dfinfo")
        while IFS='' read -r dfline
        do
            storage=$(tr -s ' ' <<< "$dfline" | cut -d ' ' -f5) #e.g. 15%
            storage_num=${storage:0:${#storage}-1} #e.g. 15

            #update file system of maximum usage
            if [ $storage_num -ge $max_storage ]
            then
                max_system=$(tr -s ' ' <<< "$dfline" | cut -d ' ' -f1) #e.g. /dev/disk1
                max_storage=$storage_num
            fi

        done <<< $df_systemonly_info
    fi

    #write host status to a text file
    if [ $ssh_return_code -ne 0 ]
    #if ssh is down, log it and we can't check file storage
    then
        fail_ssh_host=$((fail_ssh_host + 1))
        echo "$line,$ssh_return_code,NA,NA" >> $outputfile
        echo "{\"host_name\":\"$line\",\"ssh_return_code\":$ssh_return_code,\"file_storage_test\":\"NA\",\"most_used_filesystem\":\"NA\"}" >> $outputfile_json
        #append lines to history file
        echo "$line:sshUnavailable" >> $history_file
    	echo -e "${RED}$line: ssh is down${NC}"
        echo "check $outputfile for more details"
        echo "-----------------------------------------------------------------"
        #check previous status of this server and fill the entry
        fill_html_table $line

    #if ssh is up, check file storage test flag
    elif [ $max_storage -le 80 ] 
    then
    	echo "$line,$ssh_return_code,Yes,$max_system:$max_storage%" >> $outputfile
    	echo "{\"host_name\":\"$line\",\"ssh_return_code\":$ssh_return_code,\"file_storage_test\":\"Yes\",\"most_used_filesystem\":\"$max_system:$max_storage%\"}" >> $outputfile_json
    	echo -e "${GREEN}$line: passes all the test${NC}"
        echo "-----------------------------------------------------------------"
    else
        storage_exceed_host=$((storage_exceed_host + 1))
    	echo "$line,$ssh_return_code,No,$max_system:$max_storage%" >> $outputfile
    	echo "{\"host_name\":\"$line\",\"ssh_return_code\":$ssh_return_code,\"file_storage_test\":\"No\",\"most_used_filesystem\":\"$max_system:$max_storage%\"}" >> $outputfile_json
        #append lines to history file
        echo "$line:filespaceWarning" >> $history_file
    	echo -e "${RED}$line: storage system(s) usage is above 80%${NC}"
        echo "check $outputfile for more details"
        echo "-----------------------------------------------------------------"
        #check previous status of this server and fill the entry
        fill_html_table $line
	fi
done < $inputfile

echo "</table>

<a href=\"https://jenkins-oce-corp.visa.com:8443/netproc/job/OVN/job/OVN_dev/job/Administration%20Jobs/job/DailyHealthCheck/\">Check Jenkins Link</a>

</body>
</html>" >> table.html

#print daily check summary
healthy_server=$((totalhost - fail_ssh_host - storage_exceed_host))
echo -e "${BOLD}Summary${NORMAL}"
echo "*****************************************************************"
echo -e "Hosts in Total: $totalhost"
echo -e "Hosts with SSH down: ${RED}$fail_ssh_host${NC}"
echo -e "Hosts with Storage System(s) Usage Percentage above 80%: ${RED}$storage_exceed_host${NC}"
echo -e "Hosts in Good Health: ${GREEN}$healthy_server${NC}"
echo "*****************************************************************"


#add comma after each line in json except last
echo "$(awk '{printf "%s%s",sep,$0; sep=",\n"} END{print ""}' $outputfile_json)" > $outputfile_json

# Surround it with [] and have this array as a value to a corresponding key named "results". JSON Looks like: { "results":[ {} ] }
echo "]}" >> $outputfile_json
echo "$(echo -n '"results":['; cat $outputfile_json)" > $outputfile_json
#Put the date and hosts data in the beginning of the file.
echo "$(echo -n "{\"date\":\"$DATE\",\"summary\":{\"total_hosts\":$totalhost,\"fail_ssh_hosts\":$fail_ssh_host,\"storage_exceed_hosts\":$storage_exceed_host,\"healthy_hosts\":$healthy_server},"; cat $outputfile_json)" > $outputfile_json

