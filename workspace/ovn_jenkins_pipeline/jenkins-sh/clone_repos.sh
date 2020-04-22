#!/usr/bin/env bash

# File: clone_repos.sh
# Purpose:
#     To clone repositories classified under the category filter passed
# To run script:
#     ./clone_repos credentials filter
# Arguments:
#     credentials: credentials for authentication purposes
#     filter: search pattern for narrowing search to specific categories
#

UXPASS=$1
FILTER=$2
BASE_URL='https://stash.trusted.visa.com'
SLUGS=slugs.json
CATEGORIES=categories.json

clone_repos() {
    while read slug; do
        get_categories "$UXPASS" "$slug" "$CATEGORIES"
        while read category; do
            if [[ "$category" == $1 ]]; then
                git clone ssh://git@stash.trusted.visa.com:7999/op/"$slug".git
            fi
        done <"$CATEGORIES"
    done <"$SLUGS"
}

main() {
    source ../jenkins-sh/functions.sh
    get_slugs "$UXPASS" "$SLUGS"
    clone_repos $FILTER
}

main