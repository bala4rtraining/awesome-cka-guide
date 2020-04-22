#!/usr/bin/env bash

# File: generate_keywords_sql_script.sh
# Purpose:
#     To generate a SQL file containing UPDATE commands for populating
#     the "keywords" column in the Teamapp "Component" table
# To run script:
#     ./generate_keywords_sql_script.sh credentials
# Arguments:
#     credentials: credentials for authentication purposes
#

UXPASS=$1
BASE_URL='https://stash.trusted.visa.com'
SLUGS=slugs.json
CATEGORIES=categories.json
SQL=""

generate_update_commands() {
    while read slug; do
        get_categories "$UXPASS" "$slug" "$CATEGORIES"
        keywords=""
        num_of_lines=$(wc -l < "$CATEGORIES")
        line_count=0
        while read category; do
            line_count=$(expr "$line_count" + 1)
            if [[ "$line_count" -eq "$num_of_lines" ]]; then
                keywords+="$category"
            else
                keywords+="$category, "
            fi
        done < "$CATEGORIES"
        SQL+="UPDATE db.component SET keywords = '$keywords' WHERE cname = '$slug';"
    done < "$SLUGS"
}

main() {
    source jenkins-sh/functions.sh
    get_slugs "$UXPASS" "$SLUGS"
    generate_update_commands
    echo "$SQL" > update_keywords.sql
}

main