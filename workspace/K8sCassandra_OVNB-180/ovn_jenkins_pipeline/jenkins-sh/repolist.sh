#!/bin/bash

uxpass=$1

baseurl='https://stash.trusted.visa.com:7990'
DATE=`date +%Y%m%d`
curl -o response.json -X GET -u "$uxpass" $baseurl/rest/api/latest/projects/OP/repos?limit=300 
jq .values[].slug response.json > repo.list.$DATE
exit