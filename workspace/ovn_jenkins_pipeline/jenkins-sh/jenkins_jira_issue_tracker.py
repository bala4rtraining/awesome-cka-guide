#!/usr/bin/python2.7
# coding: utf-8
# File: jenkins_jira_issue_tracker.py
# Purpose:
#		To create Jira ticket automatically on Jenkins build failure and assigne it to last commiter on master branch.
#		This script will make comment if the Jira ticket is in opened or ToDo status and build it still failing, Also close ticket if build is successful.
#
# To run script/usage:
#		jenkins_jira_issue_tracker.py <success/failed <build url> <job name> <build id> <git commit> <jira user> <jira passsword>
#
import sys
import subprocess
import requests
import json

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

#script success/failed ${env.BUILD_URL} ${env.JOB_NAME} ${env.BUILD_ID} ${GIT_COMMIT} user password
build_status = sys.argv[1]
job_name = sys.argv[3]
repo_name = job_name.split('/')[-2]
label = "Jenkins-{repo_name}".format(repo_name=repo_name)
existing_jira_ticket = "https://issues.trusted.visa.com/rest/api/2/search?jql=labels%20in%20({label})%20AND%20status%20in%20(%22In%20Progress%22%2C%20%22To%20Do%22)".format(label=label)
tickets_response = requests.get(url=existing_jira_ticket, verify=False, auth=(sys.argv[6], sys.argv[7]))
tickets_response_body = tickets_response.json()

if build_status == "failed":
	command_assignee = "cut -d'@' -f1 <<< $(git log --no-merges --topo-order -n 1 --format='%ae')"
	assignee = subprocess.check_output(command_assignee, shell=True).rstrip()
	if len(tickets_response_body["issues"]) > 0:
		for issue in tickets_response_body["issues"]:
			comment_url =  'https://issues.trusted.visa.com/rest/api/2/issue/{ticket_key}/comment'.format(ticket_key=issue["key"])
			comment_data = { "body" : "Build is still failing on {repo_name}\nBuild#{build_id}\nBuild_URL={build_url}\nLast commiter is {assignee}".format(repo_name=repo_name, build_id=sys.argv[4], build_url=sys.argv[2], assignee=assignee) }
			comment_request_body = requests.post(url=comment_url, json=comment_data, verify=False, auth=(sys.argv[6], sys.argv[7]))
			print("\n\n\n ***************** Build failed, found an existing JIRA ticket https://issues.trusted.visa.com/browse/{ticket_key} hence created a new comment ***************** \n\n\n".format(ticket_key=issue["key"]))
	else:
		command_assignee = "cut -d'@' -f1 <<< $(git log --no-merges --topo-order -n 1 --format='%ae')"
		assignee = subprocess.check_output(command_assignee, shell=True).rstrip()

		description_template = """Jenkins master build #{build_id}  is failed on {repo_name}

		Build URL: {build_url}
		Last committer is: {assignee}@visa.com
		Commit number: {git_commit}

		Note: This ticket is created automatically. If you have any concern please reach out to (OVN – DEVOPS GDLOVNDEVOPS@visa.com)"""

		url = 'https://issues.trusted.visa.com/rest/api/2/issue/'
		data = { "fields": {
		    "project": { "key": "OVNB" },
		    "summary": "",
		    "description": "",
		    "labels": [label],
		    "issuetype": { "name": "Bug" },
		    "assignee": { "name": assignee } } }


		data['fields']['description'] = description_template.format(build_id=sys.argv[4], repo_name=repo_name, build_url=sys.argv[2], assignee=assignee, git_commit=sys.argv[5])
		data['fields']['summary'] = 'Jenkins Build Failure: {job_name}'.format(job_name=sys.argv[3])
		ticket_response = requests.post(url=url, json=data,  verify=False, auth=(sys.argv[6], sys.argv[7]))
		ticket_response_body = ticket_response.json()
		print("\n\n\n ***************** Build failed hence created a new JIRA ticket https://issues.trusted.visa.com/browse/{ticket_key} ***************** \n\n\n".format(ticket_key=ticket_response_body["key"]))
else:
	for issue in tickets_response_body["issues"]:
		transition_url = 'https://issues.trusted.visa.com/rest/api/2/issue/{ticketKey}/transitions'.format(ticketKey=issue["key"])
		transition_data = { 'transition': { 'id': 701 } }
		transition_response_body = requests.post(url=transition_url, json=transition_data, verify=False, auth=(sys.argv[6], sys.argv[7]))

		unassign_ticket_url = 'https://issues.trusted.visa.com/rest/api/2/issue/{ticketKey}/assignee'.format(ticketKey=issue["key"])
		assignee_data = { "name": "-1" }
		unassign_ticket_response = requests.put(url=unassign_ticket_url, json=assignee_data, verify=False, auth=(sys.argv[6], sys.argv[7]))
		print("\n\n\n ***************** Build passed hence closed and unassigned JIRA ticket https://issues.trusted.visa.com/browse/{ticket_key} ***************** \n\n\n".format(ticket_key=issue["key"]))
