#!/usr/bin/env bash

set -e

function purge() {
  # Parameters
  # 1 - regexp to match branches of particular pattern
  # 2,3 - sed compatible search and substitution patterns to extract '<barnch_name> <YYYY>-<mm>-<dd>' data from the branch name
  # 4 - how many last branches not to consider for purging
  # 5,6 - number of days after which branches are hidden, deleted

  local SELECTOR_REGEXP=$1
  local DATE_EXTRACT_REGEXP=$2
  local DATE_EXTRACT_REPLACE=$3
  local ENTRIES_TO_KEEP=$4
  local DAYS_RENAME_AFTER=$5
  local DAYS_DELETE_AFTER=$6

  [ "$ENTRIES_TO_KEEP" -ge 0 ] || { echo ENTRIES_TO_KEEP should be a non-negative number; return 1; }
  [ "$DAYS_RENAME_AFTER" -gt 0 ] || { echo DAYS_RENAME_AFTER should be greater than 0; return 1; }
  [ "$DAYS_DELETE_AFTER" -gt "$DAYS_RENAME_AFTER" ] || { echo DAYS_DELETE_AFTER should be greater than DAYS_RENAME_AFTER; return 1; }

  cat <<END
--- `date -Iminute` --- Purging branches matching $SELECTOR_REGEXP
---   Will preserve last $ENTRIES_TO_KEEP entries
---   Will purge(rename) entries older than $DAYS_RENAME_AFTER
---   Will delete entries older than $DAYS_DELETE_AFTER
END

  local NOW=$(date +%s)
  local THRESHOLD=$(($NOW-($DAYS_RENAME_AFTER+1)*3600*24))

  git branch --list |
  grep -E "^\\s*$SELECTOR_REGEXP$" |
  sort -r |
  tail -n +$((1+$ENTRIES_TO_KEEP)) |
  sed "s#^\\s*$DATE_EXTRACT_REGEXP\$#$DATE_EXTRACT_REPLACE#" |
  while read branch date_string trailer; do
    [ -z "$trailer" ] || { echo "Malformatted branch date parsing result: $branch $date_string $trailer"; continue; }
    [ -n "$date_string" ] || { echo "Malformatted branch date parsing result: $branch $date_string"; continue; }
    local unix_time=$(date -d "$date_string" +%s) || { echo "Malformatted branch date: $date_string (branch $branch)"; continue; }
    [ "$unix_time" -gt "$THRESHOLD" ] || {
      echo Renaming $branch to purged/$branch
      git branch -M $branch purged/$branch
    }
  done

  THRESHOLD=$(($NOW-($DAYS_DELETE_AFTER+1)*3600*24))

  git branch --list |
  grep -E "^\\s*purged/$SELECTOR_REGEXP$" |
  sed "s#^\\s*purged/$DATE_EXTRACT_REGEXP\$#$DATE_EXTRACT_REPLACE#" |
  while read branch date_string trailer; do
    [ -z "$trailer" ] || { echo "Malformatted branch date parsing result: $branch $date_string $trailer"; continue; }
    [ -n "$date_string" ] || { echo "Malformatted branch date parsing result: $branch $date_string"; continue; }
    local unix_time=$(date -d "$date_string" +%s) || { echo "Malformatted branch date: $date_string (branch $branch)"; continue; }
    [ "$unix_time" -gt "$THRESHOLD" ] || {
      #echo Deleting $branch
      git branch -D $branch
    }
  done
}

purge_standard() {

  local NAME="$1"
  local ENTRIES_TO_KEEP=$2
  local DAYS_RENAME_AFTER=$3
  local DAYS_DELETE_AFTER=$4

  purge \
    'build/'$NAME'/20[0-9][0-9]/[01][0-9]-[0-3][0-9]/[0-9]+' \
    'build/'$NAME'/\(20[0-9][0-9]\)/\([01][0-9]\)-\([0-3][0-9]\)/[0-9]\+' '\0 \1-\2-\3' \
    "$ENTRIES_TO_KEEP" "$DAYS_RENAME_AFTER" "$DAYS_DELETE_AFTER"
}

# main
{
  cd /data/git/pod1

  purge_standard tsung        5 30 60
  purge_standard mediator     5 30 60
  purge_standard switch       5 30 60
  purge_standard profile      5 30 60
  purge_standard currency     5 30 60
  purge_standard umf_delivery 5 30 60

  echo "--- `date -Iminute` --- Purging end"

} &>> /var/log/ovngit-purge.log
