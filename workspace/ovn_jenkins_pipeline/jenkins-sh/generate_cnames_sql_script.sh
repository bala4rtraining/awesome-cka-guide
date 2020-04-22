#!/usr/bin/env bash

# File: generate_cnames_sql_script.sh
# Purpose:
#     Generate a SQL file containing INSERT commands for 
#     adding repositories matching the specified filter
# To run script:
#     ./generate_cnames_sql_script.sh credentials filter
# Arguments:
#     credentials: credentials for authentication purposes
#     filter: search pattern for narrowing search to specific categories
#

UXPASS=$1
FILTER=$2
BASE_URL='https://stash.trusted.visa.com'
SLUGS=slugs.json
CATEGORIES=categories.json
SQL=""

generate_insert_commands() {
    while read slug; do
        get_categories "$UXPASS" "$slug" "$CATEGORIES" 
        while read category; do
            if [[ "$category" == $1 ]]; then
                SQL+="INSERT IGNORE INTO db.component SET cname = '$slug';"   
            fi     
        done < "$CATEGORIES"
    done < "$SLUGS"
}

main() {
    source jenkins-sh/functions.sh
    get_slugs "$UXPASS" "$SLUGS"
    generate_insert_commands "$FILTER"
    echo "$SQL" > insert_cnames.sql
}

main