#!/usr/bin/env bash

#===============================================================================================
#date : 07/16/2019
#title : pull.sh
#description : This script will pull the latest changes from the "golang-lta" category in Stash
#author		 : gabaguil
#args        : <api_key> - key for auth
#              <action> - indicate "clone" if cloning repos
#usage		 : pull.sh <api_key> <action> 
#===============================================================================================
BITBUCKET_API_KEY=$1
ACTION=$2
CATEGORY_LIST=categories.txt
SLUG_LIST=slugs.txt
FILTERED_SLUG_LIST=filtered_slugs.txt
CUR_DIR=$(pwd)

# filter list of slugs to include only golang-lta slugs
filter_slugs() {
    source ./functions.sh
    get_slugs "$BITBUCKET_API_KEY" "$SLUG_LIST"
    : > "$FILTERED_SLUG_LIST"
    while read slug; do
        get_categories "$BITBUCKET_API_KEY" "$slug" "$CATEGORY_LIST"
        while read category; do
            if [[ "$category" == $1 ]]; then
                echo "$slug" >> "$FILTERED_SLUG_LIST"
            fi
        done < "$CATEGORY_LIST"
    done < "$SLUG_LIST"
}

# clone or pull repos using filtered list of slugs
update_repos() {
    eval $(ssh-agent -s) && chmod 400 /ssh_key &&  ssh-add /ssh_key
    if [[ "$ACTION" == "clone" ]]; then
        while read slug; do
            echo "$slug"
            git clone -q ssh://git@stash.trusted.visa.com:7999/op/$slug.git
        done < "$FILTERED_SLUG_LIST"
    else
        while read slug; do
            echo "$slug"
            cd "$slug"
            git pull
            cd "$CUR_DIR"
        done < "$FILTERED_SLUG_LIST"
    fi
    kill -9 $SSH_AGENT_PID
}

# remove text files used for storing REST API responses
clean() {
    rm "$CATEGORY_LIST"
    rm "$SLUG_LIST"
    rm "$FILTERED_SLUG_LIST"
}

main() {
    filter_slugs "golang-lta"
    update_repos
    clean
}

main