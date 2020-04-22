#!/usr/bin/env bash

# File: check_git_tag_logical_sequence.sh
# Purpose:
#     When there is a go-moudle tag publishing event, check whether the newly added tag has
#       1) followed the tagging convention.
#       2) fit into the logical sequence by corresponding git commit date.
#
# To run script:
#     ./check_git_tag_logical_sequence.sh $TAG_TO_PUBLISH
#
# Arguments:
#     TAG_TO_PUBLISH: The tag which developer is trying to publish.
#                     The desired tag format has to follow semantic versioning, vX.Y.Z where X, Y and Z are digit numbers.
#
# Constraints:
#     ONLY support the release type tags logical sequence checking.
#     A release type tag MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.
#     X is the major version, Y is the minor version, and Z is the patch version.
#     A pre-release version which could be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version WILL NOT BE CHECKED!
#
# Script maintainer: NAOVNDEVOPS@visa.com
#

TAG_TO_PUBLISH=$1
LOG_FILE=git_logs.txt
GIT_TAG_LIST=git_tag_list.txt
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_git_tag_logical_sequence() {
    #if input is wrong, job stopped here.
    echo -e "${BLUE}[INFO]${NC} Checking if the newly added tag has followed the releasing semantic versioning convention..."
    if [[ $TAG_TO_PUBLISH =~ ^v[0-9]{1,2}\\.[0-9]{1,3}\\.[0-9]{1,3}$ ]]; then
        echo -e "${BLUE}[INFO]${NC} Tagging format checked."
    else
        echo -e "${RED}[ERROR]${NC} Tagging format is wrong, job failed with exit code 1"
        exit 1
    fi

    echo -e "${BLUE}[INFO]${NC} Parsing git logs..."
    git log --pretty='%d' | grep tag | awk '{print substr($0,3,length($0)-3)}' | sed -e 's/tag: //g' >>$LOG_FILE
    cat $LOG_FILE

    echo -e "${BLUE}[INFO]${NC} Building release tag list based on tagged commit date sequence"
    while IFS= read -r line; do
        IFS=","
        set -- $line
        tag_list=($@)
        release_tag_per_commit=0

        for tag in ${tag_list[@]}; do
            if [[ $tag =~ ^.?v[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                ((release_tag_per_commit++)) #if there are two releasing tags existed on one commit in the past, failed the job.

                if [[ $release_tag_per_commit -gt 1 ]]; then
                    echo -e "${RED}[ERROR]${NC} Can't tag multiple releasing tags to one commit , job failed with exit code 1"
                    exit 1
                fi
                echo $tag | sed -e 's/ //g' >>$GIT_TAG_LIST
            fi
        done
    done <$LOG_FILE
    cat $GIT_TAG_LIST

    echo -e "${BLUE}[INFO]${NC} Checking release tag list logical sequence"
    RELEASE_TAG_COUNT=$(wc -l $GIT_TAG_LIST | awk '{print $1}')
    #base case: one tag
    if [[ $RELEASE_TAG_COUNT -eq 1 ]]; then
        echo -e "${BLUE}[INFO]${NC} Only have one releasing tag, logical sequence check skipped."
        exit 0
    else
        arr=()
        while IFS= read -r line; do
            arr+=("$line")
        done <$GIT_TAG_LIST
    fi

    #general case: two or more tags
    ARRAY_LENGTH=${#arr[@]}
    for ((index = 1; index < $ARRAY_LENGTH; index++)); do
        newer_tag=${arr[index - 1]} #HEAD pointer always at the first commit log
        older_tag=${arr[index]}
        echo $newer_tag VS $older_tag
        if [[ "$(printf '%s\n' "$older_tag" "$newer_tag" | sort -V | head -n1)" == "$older_tag" && $older_tag != $newer_tag ]]; then
            echo "$newer_tag is higher than $older_tag"
        else
            echo -e "${RED}[ERROR]${NC} Release tag logical sequence is wrong, job failed with exit code 1"
            exit 1
        fi
    done
    echo -e "${BLUE}[INFO]${NC} Release tag logical sequence ${GREEN}CHECKED${NC}"
}

main() {
    if [ -z "$TAG_TO_PUBLISH" ]; then
        echo '***   This script will need one parameter   ***'
        echo '***   Example: sh jenkins-sh/check_git_tag_logical_sequence.sh v1.0.0   ***'
        echo '***   Job failed with exit code 1   ***'
        exit 1
    fi

    check_git_tag_logical_sequence $TAG_TO_PUBLISH
}

main
