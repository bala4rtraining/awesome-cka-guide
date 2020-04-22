#!/usr/bin/python2.7
# coding: utf-8
# File: checkmarx_parser.py
# Purpose:
#     To parse the checkmarx scan report and perform the jira related task and 
#     create output report and pass it to sheel script (checkmarx_scan_report_retrive.sh).
#
# To run script:
#     checkmarx_parser.py checkmarx_scan_report checkmarx_project_name jira_user jira_password checkmarx_project_prefix
#
import sys
import csv
import subprocess
import requests
import re
import json
import ast
from collections import OrderedDict
from io import StringIO
from datetime import date
from datetime import timedelta
import datetime

filename = sys.argv[1]
scanid = sys.argv[1].split('/')[2]
project_prefix = sys.argv[5]
f = StringIO(open(filename).read().decode('utf-8-sig'))
reader = csv.DictReader(f)
rows = []
issueDict = {}
ticketDict = {}
TicketIds = []
IssueDueDates = []
IssueCreatedDates = []
IssueLabels = []

with open('/tmp/checkmarx_project_watcher_mapping.json') as watch_mappings:
    watcher_dict = json.load(watch_mappings)

jiraDueDatesMapping = {
    'Low': 42,
    'Medium': 28,
    'High': 14,
}

descriptionTemplate = """Please note that the following items are stored in the Checkmarx database and can be traced back to an update tagged with your userid in the bitbucket “BLAME”.
To address these findings and remove them from your name, please follow the process in the following URL: https://visawiki.trusted.visa.com/display/OVN/Checkmarx+user+guide

Latest Checkmarx scan Checkmarx links of Vulnerability findings on {repo}: {desc}

For more details of scan result such as filename, line number, query ... please visit OVN Checkmarx Dashboard: http://ovndev.visa.com/teamapp2/checkmarx.html

Thanks for your help in keeping our source code clean!    (from OVN – DEVOPS GDLOVNDEVOPS@visa.com)"""

if sys.argv[2] in watcher_dict:
  watcher = watcher_dict[sys.argv[2]]
else:
  watcher = watcher_dict['DEFAULT']
watcher_data =  json.dumps(watcher)
Latest_Checkmarx_Findings = []
Existing_Checkmarx_Findings = []
Existing_Checkmarx_Findings_Ticket_Mapping = {}
Existing_Checkmarx_Findings_URL = "https://issues.trusted.visa.com/rest/api/2/search?jql=labels%20in%20({project})%20AND%20status%20in%20(%22In%20Progress%22%2C%20%22To%20Do%22)".format(project=sys.argv[2])
tickets_response = requests.get(url=Existing_Checkmarx_Findings_URL, verify=False, auth=(sys.argv[3], sys.argv[4]))
tickets_response_body = tickets_response.json()
for issue in tickets_response_body['issues']:
    ticket_labels = tuple(issue['fields']['labels'])
    Existing_Checkmarx_Findings.append(ticket_labels)
    Existing_Checkmarx_Findings_Ticket_Mapping[ticket_labels] = issue['key']

for row in reader:
    line = row['Line']
    srcFileName = row['SrcFileName']
    destLine = row['DestLine']
    destFileName = row['DestFileName']
    resultSeverity = row['Result Severity']
    srcColumn = row['Column']
    destColumn = row['DestColumn']
    command = 'git blame -L {line},+1 {srcFilename} --show-email --show-name'.format(line=line,srcFilename=srcFileName)
    srcCodeStringCommand = 'head -{line} {srcFilename} | tail -1'.format(line=line,srcFilename=srcFileName)
    output = subprocess.check_output(command, shell=True)
    srcCodeString = subprocess.check_output(srcCodeStringCommand, shell=True)
    destCommand = 'head -{destLine} {destFileName} | tail -1'.format(destLine=destLine,destFileName=destFileName)
    destCodeString = subprocess.check_output(destCommand, shell=True)
    codeStringCommitID = output.split(' ')[0]
    row['AuthorEmail'] = re.search(r"\<(.*)\>", output).group(1)
    username = row['AuthorEmail'].split('@')[0]
    label = 'Checkmarx-Unique-Code-{hashcode}'.format(hashcode=hash(codeStringCommitID + srcCodeString + destCodeString + srcColumn + destColumn))
    IssueLabels.append(label)
    data = { "fields": { 
    "project": { "key": "OVNB" },
    "summary": "", 
    "duedate": "",
    "description":"", 
    "customfield_12483":"OVNB-1580",
    "labels":["{label}".format(label=label), sys.argv[2]],
    "issuetype": { "name": "Bug" }, 
    "assignee": { "name": "" } } }
    desc = row['Link']
    repo = sys.argv[2].split(project_prefix)[1]
    url = 'https://issues.trusted.visa.com/rest/api/2/issue/'
    epic_url = 'https://issues.trusted.visa.com/rest/agile/1.0/epic/1655770/issue'
    data['fields']['summary'] = 'Checkmarx Scan Vulnerability Findings - {project}'.format(project=sys.argv[2])
    data['fields']['description'] = descriptionTemplate.format(repo=repo,desc=desc)
    data['fields']['assignee']['name'] = username
    noOfDaysToBeAdded = jiraDueDatesMapping[resultSeverity]
    data['fields']['duedate'] = (date.today() + timedelta(days=noOfDaysToBeAdded)).strftime('%Y-%m-%d')
    ticket_labels = ("{label}".format(label=label), sys.argv[2])
    Latest_Checkmarx_Findings.append(ticket_labels)
    if ticket_labels not in Existing_Checkmarx_Findings:
        response = requests.post(url=url, json=data,  verify=False, auth=(sys.argv[3], sys.argv[4]))
        responseBody = response.json()
        if ('key' not in responseBody):
            data['fields'].pop('assignee');
            response = requests.post(url=url, json=data,  verify=False, auth=(sys.argv[3], sys.argv[4]))
            responseBody = response.json()
        ticketKey = responseBody['key']
        TicketIds.append(ticketKey)
        IssueDueDates.append(datetime.datetime.strptime(data['fields']['duedate'], '%Y-%m-%d').date().strftime('%m-%d-%Y'))
        IssueCreatedDates.append(date.today().strftime('%m-%d-%Y'))
        watcher_url = 'https://issues.trusted.visa.com/rest/api/2/issue/{ticketKey}/watchers'.format(ticketKey=ticketKey)
        response_watcher = requests.post(url=watcher_url, data=watcher_data, verify=False, auth=(sys.argv[3], sys.argv[4]))
    else:
        key = Existing_Checkmarx_Findings_Ticket_Mapping[ticket_labels]
        comment_url =  'https://issues.trusted.visa.com/rest/api/2/issue/{ticket_key}/comment'.format(ticket_key=key)
        comment_data = { "body" : "Finding reoccured on scanid#{scanid}".format(scanid=scanid) }
        comment_request_body = requests.post(url=comment_url, json=comment_data, verify=False, auth=(sys.argv[3], sys.argv[4]))
        TicketIds.append(key)
        duedate_url = 'https://issues.trusted.visa.com/rest/api/2/issue/{ticket_key}'.format(ticket_key=key)
        duedate_response = requests.get(url=duedate_url, verify=False, auth=(sys.argv[3], sys.argv[4]))
        duedate_response_body = duedate_response.json()
        duedate = datetime.datetime.strptime(duedate_response_body['fields']['duedate'], '%Y-%m-%d').date()
        IssueDueDates.append(duedate.strftime('%m-%d-%Y'))
        print((duedate - timedelta(days=noOfDaysToBeAdded)).strftime('%m-%d-%Y'))
        IssueCreatedDates.append((duedate - timedelta(days=noOfDaysToBeAdded)).strftime('%m-%d-%Y'))

tickets_to_be_closed = list(set(Existing_Checkmarx_Findings) - set(Latest_Checkmarx_Findings))
for ticket in tickets_to_be_closed:
    ticket_key = Existing_Checkmarx_Findings_Ticket_Mapping[ticket]
    transition_url = 'https://issues.trusted.visa.com/rest/api/2/issue/{ticketKey}/transitions'.format(ticketKey=ticket_key)
    transition_data = { 'transition': { 'id': 701 }, 'fields': { 'resolution': { 'name': 'Done' } } }
    transition_response_body = requests.post(url=transition_url, json=transition_data, verify=False, auth=(sys.argv[3], sys.argv[4]))

header = {}

f1 = StringIO(open(filename).read().decode('utf-8-sig'))
reader2 = csv.DictReader(f1)

row_index = 0    
for row in reader2:
    row['TicketId'] = TicketIds[row_index]
    row['IssueCreatedDate'] = IssueCreatedDates[row_index]
    row['IssueDueDate'] = IssueDueDates[row_index]
    row['IssueLabel'] = IssueLabels[row_index]
    line = row['Line']
    srcFileName = row['SrcFileName']
    commandToFetchAuthorName = 'git blame -L {line},+1 {srcFilename}'.format(line=line,srcFilename=srcFileName)
    commandToFetchAuthorEmail = 'git blame -L {line},+1 {srcFilename} --show-email --show-name'.format(line=line,srcFilename=srcFileName)
    authorNameOutput = subprocess.check_output(commandToFetchAuthorName, shell=True)
    authorEmailOutput = subprocess.check_output(commandToFetchAuthorEmail, shell=True)
    row['AuthorEmail'] = re.search(r"\<(.*)\>", authorEmailOutput).group(1)
    row['AuthorName'] = re.search(r"\(([a-zA-Z|,|\s]*)", authorNameOutput).group(1)
    username = row['AuthorEmail'].split('@')[0]
    rows.append(row)
    row_index = row_index + 1

orderedKeys = [("Query",None),("QueryPath",None),
("Custom", None),("PCI DSS v3.2",None),
("OWASP Top 10 2013",None),
("FISMA 2014", None),
("NIST SP 800-53", None),
("OWASP Top 10 2017", None),
("OWASP Mobile Top 10 2016", None),
("SrcFileName", None),("Line", None),
("Column", None),("NodeId", None),
("Name", None),("DestFileName", None),
("DestLine", None),("DestColumn", None),
("DestNodeId", None),("DestName", None),
("Result State", None),("Result Severity", None),
("Assigned To", None),("Comment", None),
("Link", None),("Result Status", None), 
('AuthorEmail', None), ('AuthorName', None), ('TicketId', None),
('IssueCreatedDate', None), ('IssueDueDate', None), ('IssueLabel', None)]

keys = OrderedDict(orderedKeys) 

with open(filename, 'w') as output_file:
    dictwriter = csv.DictWriter(output_file, keys)
    dictwriter.writeheader()
    dictwriter.writerows(rows)
