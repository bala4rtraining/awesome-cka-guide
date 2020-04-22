#!/usr/bin/python2.7
# coding: utf-8
# File: repo_data_retrieve_for_component_table.py
# Purpose:
#     To automatically update teamapp component table with new repositories names and 
#     remove deleted repositories names.
#
# To run script:
#     repo_data_retrieve_for_component_table.py bitbucket_user bitbucket_password ovn_database_user ovn_database_password
#
import sys
import subprocess
import requests
import re
import csv
import json
import MySQLdb
from collections import OrderedDict

# SQL query to pull the repo name from OVN database
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

filename = 'component_table_repo_update.sql'
old_repo_name = []
new_rows_dict = dict.fromkeys(['cname','keywords'])
rows = []
database_user = sys.argv[3]
database_pass = sys.argv[4]
connection = MySQLdb.connect (host = "sl73ovnapd112",
                              user = database_user,
                              passwd = database_pass,
                              db = "db")
cursor = connection.cursor(MySQLdb.cursors.DictCursor)
cursor.execute("SELECT cname FROM component")
result_set = cursor.fetchall()
for row in result_set:
  old_repo_name.append(row["cname"])
cursor.close()
repo_name_list = []
keyword_list = []

# API request to pull the latest repo names from bitbucket and update OVN database
latest_repo_names =[]
component_category = ["golang-lta", "dsl-lta"]
latest_repo_name_url = "https://stash.trusted.visa.com:7990/rest/api/latest/projects/OP/repos?limit=200"
category_url = "https://stash.trusted.visa.com/rest/categories/latest/project/OP/repository/"
repo_response = requests.get(url=latest_repo_name_url, verify=False, auth=(sys.argv[1], sys.argv[2]))
repo_response_body = repo_response.json()
new_rows_dict_index = 0
for repo in repo_response_body["values"]:
    category_repo_url = "https://stash.trusted.visa.com/rest/categories/latest/project/OP/repository/{repo_name}".format(repo_name=repo["name"])
    category_response = requests.get(url=category_repo_url, verify=False, auth=(sys.argv[1], sys.argv[2]))
    category_response_body = category_response.json()
    for category in category_response_body["result"]["categories"]:
        if category["title"] in component_category and repo["name"] not in old_repo_name:
            repo_name_list.append(repo["name"])    
            keyword_list.append(category["title"])
            print(" *********** New repo {cname_value} found in Bitbucket *********** ").format(cname_value=repo["name"])

filename = '/tmp/repo_data_upload.csv'
csv = open(filename, "w")
title = "cname" + "," + "keywords" + "\n"
csv.write(title)

for i in range(len(repo_name_list)):
  value = repo_name_list[i] + "," + keyword_list[i] + "\n"
  csv.write(value)