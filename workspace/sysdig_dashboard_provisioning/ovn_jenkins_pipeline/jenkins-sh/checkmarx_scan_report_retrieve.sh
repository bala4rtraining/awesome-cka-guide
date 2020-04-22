#!/bin/bash
# File: checkmarx_scan_report_retrive.sh
# Purpose:
#     To perform checkmarx task including checkmarx API token generate step,
#     create checkmarx scan report, execute python script (checkmarx_parser.py),
#     create sql dump from python output report and upload it to OVN Checkmarx SQL Server.
#
# To run script:
#     checkmarx_scan_report_retrive.sh checkmarx_project_name jenkins_build_tag checkmarx_service_account_password jira_user jira_password
#

project_name_checkmarx=$1
BUILD_TAG=$2
checkmarx_token=$3
jira_service_account_user=$4
jira_service_account_password=$5
checkmarx_project_prefix=$6
ovn_database_user=$7
ovn_database_password=$8


echo -e "\n\n-----Generate token to access Checkmarx API's-----"
token=$(curl -X POST \
https://sast.visa.com/cxrestapi/auth/identity/connect/token \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-d 'grant_type=password&scope=sast_rest_api&client_id=resource_owner_client&client_secret=014DF517-39D1-4453-B7B3-9930C563627C&username=NP_OVN_SAST_USER&undefined=' \
--data-urlencode "password=$checkmarx_token" | jq -r .access_token)
if [ -z "$token" ]
then
  exit 1
else
  echo "token = $token"
fi

echo -e "\n\n-----Create a project in Checkmarx for Golang Repo-----"
curl -X POST \
https://sast.visa.com/cxrestapi/projects \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-H 'cxOrigin: cx-jenkins' \
-d "Project=$project_name_checkmarx&name=$project_name_checkmarx&owningTeam=2385dc03-b538-4dfb-a7f2-932c2e383425&isPublic=true&undefined="

echo -e "\n\n-----Get project id for checkmarx project-----"
project_id=$(curl -X GET \
https://sast.visa.com/cxrestapi/projects \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-d undefined= | jq --arg project_name $project_name_checkmarx '.[] | select(.name==$project_name)' | jq -r '.id')
if [ -z "$project_id" ]
then
  exit 1
else
  echo "project_id = $project_id"
fi

echo -e "\n\n-----Configure Checkmarx scan settings for checkmarx project-----"
curl -X POST \
https://sast.visa.com/cxrestapi/sast/scanSettings \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-H 'cxOrigin: cx-jenkins' \
-d "scanSettings=scan%20settings&projectId=$project_id&presetId=100003&engineConfigurationId=1&undefined="

echo -e "\n\n-----Upload compressed golang source code to checkmarx project-----"
curl -X POST \
https://sast.visa.com/cxrestapi/projects/$project_id/sourceCode/attachments \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: multipart/form-data' \
-H 'cache-control: no-cache' \
-H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' \
-F zippedSource=@/tmp/golang_repo.zip

echo -e "\n\n-----Trigger Checkmarx scan and get scan_id-----"
scan_id=$(curl -X POST \
https://sast.visa.com/cxrestapi/sast/scans \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'cache-control: no-cache' \
-H 'cxOrigin: cx-jenkins' \
-d "scan=CheckmarxScan&projectId=$project_id&isIncremental=false&forceScan=false&comment=$BUILD_TAG&undefined=" | jq -r '.id')
if [ -z "$scan_id" ]
then
  exit 1
else
  echo "scan_id = $scan_id"
fi

echo -e "\n\n-----Wait for scan to be Finished-----"
scan_status=''
while [ "$scan_status" != "Finished" ]; do
  sleep 60
  scan_status=$(curl -X GET \
  https://sast.visa.com/cxrestapi/sast/scans/$scan_id \
  -H 'Authorization: Bearer '$token'' \
  -H 'Content-Type: application/csv' \
  -H 'cache-control: no-cache' | jq -r '.status.name')
  if [ "$scan_status" == "failed" ]
  then
    echo "Checkmarx scan failed"
    exit 1
  fi
  echo "scan_status = $scan_status"
done
echo "Scan is Finished"

echo -e "\n\n-----Creat CSV Checkmarx scan report and get report_id-----"
report_id=$(curl -X POST \
https://sast.visa.com/cxrestapi/reports/sastScan \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/json' \
-H 'cache-control: no-cache' \
-d '{
  "scanId": '$scan_id',
  "reportType": "csv"
}' | jq -r .reportId )

if [ -z "$report_id" ]
then
  exit 1
else
  echo "report_id = $report_id"
fi

echo -e "\n\n-----Wait for scan report to be Created-----"
report_status=''
while [ "$report_status" != "Created" ]; do
  sleep 10
  report_status=$(curl -X GET \
  https://sast.visa.com/cxrestapi/reports/sastScan/$report_id/status \
  -H 'Authorization: Bearer '$token'' \
  -H 'Content-Type: application/csv' \
  -H 'cache-control: no-cache' | jq -r '.status.value' )
  echo "report_status = $report_status"
done
echo "Scan Report is Created"

echo -e "\n\n-----Copy the scan report to /tmp -----"
curl -X GET \
https://sast.visa.com/cxrestapi/reports/sastScan/$report_id \
-H 'Authorization: Bearer '$token'' \
-H 'Content-Type: application/csv' \
-H 'cache-control: no-cache' > /tmp/scan_$scan_id

echo -e "\n\n-----Execute checkmarx_parser.py to create Jira Tickets add Author's field, Tickets in Checkmarx report-----"
/tmp/checkmarx_parser.py /tmp/scan_$scan_id $project_name_checkmarx $jira_service_account_user $jira_service_account_password $checkmarx_project_prefix


inputfile="/tmp/scan_$scan_id"

if [[ $(cat "$inputfile" | wc -l) > 1 ]]; then
echo -e "\n\n-----Creat importcxdata.sql and  cxdata.csv file------"
cat > /tmp/importcxdata.sql <<EOL
SET @SCANID=${scan_id};
SET @USER='jenkins';
SET @PROJECT='${project_name_checkmarx}';
SET @IMPORTDATE=NOW();
LOAD DATA LOCAL INFILE '/tmp/cxdata.csv' INTO TABLE checkmarx FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (cxi_query, cxi_querypath, cxi_custom, cxi_pcidss_dss, cxi_owasp_top_10_2013, cxi_fisma_2014, cxi_nist_sp_800_53, cxi_owasp_top_10_2017, cxi_owasp_mobile_top_10_2016, cxi_srcfilename, cxi_srcline, cxi_srccolumn, cxi_srcnodeid, cxi_srcname, cxi_destfilename, cxi_destline, cxi_destcolumn, cxi_destnodeid, cxi_destname, cxi_result_state, cxi_result_severity, cxi_assigned_to, cxi_comment, cxi_link, cxi_result_status, cxi_authoremail, cxi_authorname, ticketid, issuecreateddate, issueduedate, issuelabel ) SET project=@PROJECT,importscanid=@SCANID,importdatetime=@IMPORTDATE,importuser=@USER;
SHOW WARNINGS;
EOL
cat "$inputfile" | tr '\' '/' | tr -d '\r' > /tmp/cxdata.csv
else
echo -e "\n\n-----No Checkmarx finding found, updating Checkmarx table with no findings-----"
echo "No checkmarx findings found" > $inputfile
link="https://sw730vasapa006.visa.com/CxWebClient/ViewerMain.aspx?scanId=$scan_id&ProjectID=$project_id"
cat > /tmp/importcxdata.sql <<EOL
INSERT INTO checkmarx (finding_found, project, cxi_link, importscanid, importdatetime, importuser) values ('no', '${project_name_checkmarx}', '$link', '${scan_id}', NOW(), 'jenkins');
SHOW WARNINGS;
EOL
fi

echo -e "\n\n-----Upload data to OVN Checkmarx table server-----"
cat /tmp/importcxdata.sql
/usr/bin/mysql -h sl73ovnapd112 -P 3306 -u$ovn_database_user -p$ovn_database_password  db < "/tmp/importcxdata.sql"
cp /tmp/scan_$scan_id scan_report.txt
