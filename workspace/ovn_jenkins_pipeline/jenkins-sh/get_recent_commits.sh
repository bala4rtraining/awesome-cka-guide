#!/usr/bin/env bash
# File: get_recent_commits.sh
# Purpose:
#     To get the most recent commit on the disabled_playbooks.
# To run script:
#     ./get_recent_commits path/to/repository_folder path/to/playbook_names path/to/commits_list
# Arguments:
#     repository_folder: the repository whose playbooks need to be checked.
#     playbook_names: the path to disabled playbook names from the repository root listed in a file
#     commits_list: output file where the most recent commit of the above files are written.
#
branch_name="$1"
git clone -b $branch_name ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git || true
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
jenkins_root=$(dirname -- "$DIR")
repository_folder=$jenkins_root"/ovn_infrastructure"
playbook_names=$DIR'/disabled_playbooks.txt'
outputfilename=$jenkins_root"/recent_playbooks_commit_${branch_name//-}.txt"

if [[ -f $outputfilename ]]; then
  rm $outputfilename
fi
touch $outputfilename

cd $repository_folder

while line='' read -r line || [[ -n "$line" ]]; do
  if [[ -f $line ]]; then
    last_commit=$(git log -n 1 --pretty=format:%H -- $line | cat)
    echo "$line=$last_commit" >> $outputfilename
  else
    echo "############# $line not found  ####################"
  fi
done < $playbook_names
rm -r $repository_folder
