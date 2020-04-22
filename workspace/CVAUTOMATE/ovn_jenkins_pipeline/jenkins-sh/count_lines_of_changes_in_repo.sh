#!/usr/bin/env bash

# File: count_lines_of_changes_in_repo.sh
# Purpose:
#     Change directory into each LTA repos, count lines of addition, removal on the master branch
#     and record the lines of change for the epic branch with most significant development.
# To run script:
#     ./count_lines_of_changes_in_repo 21 ovn-lta/
#     Generate the code change csv report for the past 21 days (not including today), from the repos inside ovn-lta/ folder
# Arguments:
#     duration: The duration you want for the report
#     base_dir: The base directory of already checked out git repos to be counted
#
# Script maintainer: NAOVNDEVOPS@visa.com
#

DURATION=$1
BASE_DIR=$2
OUTPUT_FILE=line-of-code-weekly-report.csv
EXCLEXTS="dsl.go,dsl.pb.go,txt,log,sum"
EXCLOPTIONS="--exclude-list-file=excl.lst --exclude-ext=$EXCLEXTS"
EXCLSTRING="$(echo $EXCLEXTS | sed -E -e 's/,/ /g' -e 's/([^ ]+)/:(exclude)*.\1/g')"
CHECK_DATE_AFTER=$(date -d "-$DURATION days" +%Y-%m-%d)
CHECK_DATE_BEFORE=$(date -d "-1 day" +%Y-%m-%d)

count_lines_of_changes_in_repo() {
    if [[ $# -eq 0 ]]; then
        echo '*** This script will need two parameters ***'
        echo '*** Example: sh jenkins-sh/count_lines_of_changes_in_repo.sh 21 ovn-lta/ ***'
        echo '*** Job failed with exit code 1 ***'
        exit 1
    fi
    
    echo "cloning exclude list from ovn_jenkins_pipeline..."
    echo "Files with the extension listed in the exclude list will not be counted"
    git clone ssh://git@stash.trusted.visa.com:7999/op/ovn_jenkins_pipeline.git
    cp ovn_jenkins_pipeline/excl.lst ovn-lta/
    cd $BASE_DIR
    echo "Creating line-of-code-weekly-report.csv file..."
    touch $OUTPUT_FILE
    echo "Report from $CHECK_DATE_AFTER to $CHECK_DATE_BEFORE" >>$OUTPUT_FILE
    echo repo_name,lines_of_code,master_additions,master_removal,major_epic_branch >>$OUTPUT_FILE

    for dir in */; do
        if [ "$(cd $dir && git log -n 1)" ]; then
            cd "$dir"

            ADDITION="0"
            REMOVAL="0"
            MAJOR_EPIC_BRANCH_Lines_of_Code=0
            COMMIT_ID=$(git log --first-parent --after="$CHECK_DATE_AFTER" --before="$CHECK_DATE_BEFORE" --pretty=format:"%h" | tail -1)
            DIFF_MESSAGE="$(git diff --shortstat $COMMIT_ID master $EXCLSTRING)"
            echo $DIFF_MESSAGE

            if [[ $(echo $DIFF_MESSAGE | awk '{print $4}') != "" ]]; then
                ADDITION="+$(echo $DIFF_MESSAGE | awk '{print $4}')"
            fi

            if [[ $(echo $DIFF_MESSAGE | awk '{print $6}') != "" ]]; then
                REMOVAL="-$(echo $DIFF_MESSAGE | awk '{print $6}')"
            fi

            for branch in $(git branch -a | grep remotes/origin/epic-); do
                git checkout $branch -q
                NUM_of_Lines=$(cloc --vcs git | tail -2 | awk '{print $5}')
                if [ "$NUM_of_Lines" -gt "$MAJOR_EPIC_BRANCH_Lines_of_Code" ]; then
                    MAJOR_EPIC_BRANCH_Lines_of_Code=$NUM_of_Lines
                fi
            done

            MESSAGE="${dir:0:${#dir}-1},$(cloc $EXCLOPTIONS --vcs git | tail -2 | awk '{print $5}'),$ADDITION,$REMOVAL,$MAJOR_EPIC_BRANCH_Lines_of_Code"

            cd ..
            echo $MESSAGE >>$OUTPUT_FILE
        else
            echo "$dir has no commit, cloc checking step skipped..."
        fi
    done
}

main() {
    count_lines_of_changes_in_repo $DURATION $BASE_DIR
    cat $OUTPUT_FILE
}

main
