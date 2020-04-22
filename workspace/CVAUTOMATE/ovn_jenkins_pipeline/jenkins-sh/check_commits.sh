#!/usr/bin/env bash
# File: check_commits.sh
# Purpose:
#     To check if any of disabled playbooks have any new commits
# To run script:
#     ./check_commits path/to/repository_folder path/to/playbook_names path/to/commits_list path/to/changed_playbooks
# Arguments:
#     repository_folder: the repository whose playbooks need to be checked.
#     playbook_names: the path to disabled playbook names from the repository root listed in a file
#     commits_list: generated list of commits for the playbook_names(Use get_recent_commits.sh)
#     changed_playbooks: Output file where the changed playbooks are listed.
#

branch_name="$1"
git clone -b $branch_name ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git || true
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
jenkins_root=$(dirname -- "$DIR")
repository_folder=$jenkins_root"/ovn_infrastructure"
playbook_names=$DIR'/disabled_playbooks.txt'

commits_list=$jenkins_root"/commits_list/recent_playbooks_commit_${branch_name//-}.txt" #"current_commits.txt"
changed_playbooks=$jenkins_root"/changed_playbooks_${branch_name//-}.txt"$4 #"changed_playbooks.txt"
if [[ -f $changed_playbooks ]]; then
  rm $changed_playbooks
fi
touch $changed_playbooks
cd $repository_folder
any_changes=false

while line='' read -r line || [[ -n "$line" ]]; do
    current_commit=$(git log -n 1 --pretty=format:%H -- $line | cat)
    last_commit=$(sed -n 's|^'$line'=||p' $commits_list)
    if [[ -f $line ]]; then
      if [[ $last_commit != $current_commit ]]; then
        echo "$line, $last_commit, $current_commit" >> $changed_playbooks
        any_changes=true
      fi
      else
      echo "############# $line not found  ####################"
    fi
done < $playbook_names
rm -r $repository_folder
if [[ "$any_changes" == true ]]; then
  exit 12
else
  exit 0
fi
