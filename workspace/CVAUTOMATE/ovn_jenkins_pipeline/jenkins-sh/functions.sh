#!/usr/bin/env bash

# File: functions.sh
# Purpose:
#     To serve as a collection of reusable functions within the OVN
#     environment
# To use a function below:
#     1. Load functions.sh file in your script: source functions.sh
#     2. Invoke the function in your script
#


# Retrieves the repository slugs/names from Stash (e.g. "ovn-components", "ovn-commons")
# How to use:
#      get_slugs credentials output_file
# Arguments:
#      credentials: credentials for authentication purposes pulling from stash
#      output_file: file for storing the output
#
get_slugs() {
    curl -s -o response-repos.json -X GET -u "$1" -H "Content-Type: application/json" $BASE_URL/rest/api/latest/projects/OP/repos?limit=200
    jq -r .values[].slug response-repos.json > "$2"
}

# Retrieves categories for the specified repository name
# How to use:
#      get_categories credentials repository output_file
# Arguments:
#      credentials: credentials for authentication purposes pulling from stash
#      repository: name of the repository you want to get the categories of
#      output_file: file for storing the output
#
get_categories() {
    curl -s -o response-categories.json -X GET -u "$1" -H "Content-Type: application/json" $BASE_URL/rest/categories/latest/project/OP/repository/"$2" 
    jq -r .result.categories[].title response-categories.json > "$3"
}
